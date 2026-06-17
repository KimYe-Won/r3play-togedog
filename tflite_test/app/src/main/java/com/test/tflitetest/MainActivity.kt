package com.test.tflitetest

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Paint
import android.os.Bundle
import android.util.Size
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size as ComposeSize
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import com.test.tflitetest.ui.theme.TfliteTestTheme
import android.os.Handler
import android.os.Looper
import android.util.Log
import java.util.concurrent.Executors

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            TfliteTestTheme {
                TfliteTestApp()
            }
        }
    }
}

@Composable
fun TfliteTestApp() {
    val context = LocalContext.current
    var hasPermission by remember {
        mutableStateOf(ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED)
    }
    val launcher = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) {
        hasPermission = it
    }
    LaunchedEffect(Unit) {
        if (!hasPermission) launcher.launch(Manifest.permission.CAMERA)
    }

    if (hasPermission) CameraScreen()
    else Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text("카메라 권한이 필요합니다", fontSize = 18.sp)
    }
}

@Composable
fun CameraScreen() {
    val context = LocalContext.current
    val detector = remember { YoloDetector(context) }
    DisposableEffect(Unit) { onDispose { detector.close() } }

    var detections by remember { mutableStateOf<List<DetectionResult>>(emptyList()) }
    var latencyMs by remember { mutableLongStateOf(0L) }
    var fps by remember { mutableFloatStateOf(0f) }
    var rawCx by remember { mutableFloatStateOf(0f) }
    var rawCy by remember { mutableFloatStateOf(0f) }
    var rawScore by remember { mutableFloatStateOf(0f) }

    val previewViewRef = remember { mutableStateOf<PreviewView?>(null) }

    LaunchedEffect(previewViewRef.value) {
        val previewView = previewViewRef.value ?: return@LaunchedEffect
        val lifecycleOwner = context as androidx.lifecycle.LifecycleOwner
        val providerFuture = ProcessCameraProvider.getInstance(context)
        providerFuture.addListener({
            val provider = providerFuture.get()
            val preview = Preview.Builder().build().also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }
            val analysis = ImageAnalysis.Builder()
                .setTargetResolution(Size(640, 480))
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build()

            var frameCount = 0
            var fpsWindowStart = System.currentTimeMillis()
            val executor = Executors.newSingleThreadExecutor()
            val mainHandler = Handler(Looper.getMainLooper())

            analysis.setAnalyzer(executor) { proxy: ImageProxy ->
                val start = System.currentTimeMillis()
                val bmp = proxy.toBitmap()
                val rotation = proxy.imageInfo.rotationDegrees
                proxy.close()

                val results = detector.detect(bmp, rotation)
                val elapsed = System.currentTimeMillis() - start
                Log.d("TFLiteTest", "det=${results.size} latency=${elapsed}ms rotation=$rotation")

                frameCount++
                val now = System.currentTimeMillis()
                val newFps = if (now - fpsWindowStart >= 1000L) {
                    val f = frameCount * 1000f / (now - fpsWindowStart)
                    frameCount = 0
                    fpsWindowStart = now
                    f
                } else null

                mainHandler.post {
                    detections = results
                    latencyMs = elapsed
                    if (newFps != null) fps = newFps
                    rawCx = detector.debugMaxCx
                    rawCy = detector.debugMaxCy
                    rawScore = detector.debugMaxScore
                }
            }

            provider.unbindAll()
            provider.bindToLifecycle(lifecycleOwner, CameraSelector.DEFAULT_BACK_CAMERA, preview, analysis)
        }, ContextCompat.getMainExecutor(context))
    }

    Box(Modifier.fillMaxSize()) {
        AndroidView(
            factory = { ctx ->
                PreviewView(ctx).apply {
                    scaleType = PreviewView.ScaleType.FILL_CENTER
                }.also { previewViewRef.value = it }
            },
            modifier = Modifier.fillMaxSize()
        )

        DetectionOverlay(detections = detections, modifier = Modifier.fillMaxSize())

        // Stats panel
        val topPad = WindowInsets.statusBars.asPaddingValues().calculateTopPadding()
        Box(
            Modifier
                .align(Alignment.TopStart)
                .padding(top = topPad + 4.dp, start = 4.dp)
                .background(Color.Black.copy(alpha = 0.55f))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Text(
                text = "FPS: ${"%.1f".format(fps)}  |  ${latencyMs}ms  |  Det: ${detections.size}\ncx=${"%.3f".format(rawCx)} cy=${"%.3f".format(rawCy)} score=${"%.2f".format(rawScore)}",
                color = Color.White,
                fontSize = 12.sp
            )
        }
    }
}

@Composable
fun DetectionOverlay(detections: List<DetectionResult>, modifier: Modifier = Modifier) {
    val classColors = remember {
        listOf(
            Color(0xFFE53935), Color(0xFF8E24AA), Color(0xFF1E88E5), Color(0xFF00ACC1),
            Color(0xFF43A047), Color(0xFFFB8C00), Color(0xFFFFD600), Color(0xFF6D4C41),
            Color(0xFF00BFA5), Color(0xFFAA00FF), Color(0xFF304FFE), Color(0xFF00C853)
        )
    }
    val textPaint = remember {
        Paint().apply {
            color = android.graphics.Color.WHITE
            textSize = 36f
            isAntiAlias = true
            setShadowLayer(3f, 1f, 1f, android.graphics.Color.BLACK)
        }
    }
    Canvas(modifier) {
        val w = size.width
        val h = size.height
        for (d in detections) {
            val color = classColors[d.classId % classColors.size]
            val left   = d.left   * w
            val top    = d.top    * h
            val right  = d.right  * w
            val bottom = d.bottom * h
            drawRect(
                color = color,
                topLeft = Offset(left, top),
                size = ComposeSize(right - left, bottom - top),
                style = Stroke(width = 4f)
            )
            drawContext.canvas.nativeCanvas.drawText(
                "${"%.0f".format(d.confidence * 100)}% ${d.className}",
                left + 4f,
                maxOf(top - 8f, 36f),
                textPaint.apply { this.color = color.toArgb() }
            )
        }
    }
}