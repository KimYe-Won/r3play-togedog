package com.test.tflitetest

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import android.util.Log
import org.tensorflow.lite.Interpreter
import java.io.Closeable
import java.nio.ByteBuffer
import java.nio.ByteOrder

class YoloDetector(context: Context) : Closeable {

    companion object {
        private const val MODEL_FILE = "best_v3_float16.tflite"
        private const val INPUT_SIZE = 640
        private const val CONF_THRESHOLD = 0.25f
        private const val IOU_THRESHOLD = 0.45f
        // Order from model metadata (metadata.json inside .tflite)
        val CLASS_NAMES = arrayOf(
            "person", "stairs", "dog", "chair", "pole_obstacle",
            "car", "bicycle", "crosswalk", "traffic_light", "table",
            "scooter", "motorcycle"
        )
        private const val NUM_CLASSES = 12
        private const val NUM_ANCHORS = 8400
    }

    private val interpreter: Interpreter
    // Pre-allocated buffers to reduce GC pressure
    private val inputBuffer: ByteBuffer = ByteBuffer
        .allocateDirect(INPUT_SIZE * INPUT_SIZE * 3 * 4)
        .order(ByteOrder.nativeOrder())
    private val outputBuffer: Array<Array<FloatArray>> =
        Array(1) { Array(4 + NUM_CLASSES) { FloatArray(NUM_ANCHORS) } }
    private val pixels = IntArray(INPUT_SIZE * INPUT_SIZE)

    init {
        val bytes = context.assets.open(MODEL_FILE).readBytes()
        val modelBuffer = ByteBuffer.allocateDirect(bytes.size).order(ByteOrder.nativeOrder())
        modelBuffer.put(bytes)
        modelBuffer.rewind()
        interpreter = Interpreter(modelBuffer, Interpreter.Options().apply { numThreads = 4 })
    }

    fun detect(bitmap: Bitmap, rotationDegrees: Int = 0): List<DetectionResult> {
        val upright = if (rotationDegrees != 0) {
            val m = Matrix().apply { postRotate(rotationDegrees.toFloat()) }
            Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, m, true)
        } else bitmap

        val scaled = Bitmap.createScaledBitmap(upright, INPUT_SIZE, INPUT_SIZE, true)
        fillInputBuffer(scaled)

        interpreter.run(inputBuffer, outputBuffer)

        return postProcess(outputBuffer[0])
    }

    private fun fillInputBuffer(bitmap: Bitmap) {
        bitmap.getPixels(pixels, 0, INPUT_SIZE, 0, 0, INPUT_SIZE, INPUT_SIZE)
        inputBuffer.rewind()
        for (pixel in pixels) {
            inputBuffer.putFloat((pixel shr 16 and 0xFF) / 255f)
            inputBuffer.putFloat((pixel shr 8 and 0xFF) / 255f)
            inputBuffer.putFloat((pixel and 0xFF) / 255f)
        }
        inputBuffer.rewind()
    }

    // Exposed for on-screen debug display: raw cx/cy of top-scoring anchor
    var debugMaxCx = 0f; var debugMaxCy = 0f; var debugMaxScore = 0f

    private fun postProcess(raw: Array<FloatArray>): List<DetectionResult> {
        var globalMax = 0f; var globalMaxIdx = 0; var globalMaxClass = 0
        for (i in 0 until NUM_ANCHORS) {
            for (c in 0 until NUM_CLASSES) {
                val s = raw[4 + c][i]
                if (s > globalMax) { globalMax = s; globalMaxIdx = i; globalMaxClass = c }
            }
        }
        debugMaxCx = raw[0][globalMaxIdx]
        debugMaxCy = raw[1][globalMaxIdx]
        debugMaxScore = globalMax

        val candidates = mutableListOf<DetectionResult>()
        for (i in 0 until NUM_ANCHORS) {
            var maxScore = 0f
            var maxClass = 0
            for (c in 0 until NUM_CLASSES) {
                val score = raw[4 + c][i]
                if (score > maxScore) { maxScore = score; maxClass = c }
            }
            if (maxScore < CONF_THRESHOLD) continue

            val cx = raw[0][i]
            val cy = raw[1][i]
            val w  = raw[2][i]
            val h  = raw[3][i]

            candidates.add(DetectionResult(
                classId = maxClass,
                className = CLASS_NAMES[maxClass],
                confidence = maxScore,
                left   = (cx - w / 2f).coerceIn(0f, 1f),
                top    = (cy - h / 2f).coerceIn(0f, 1f),
                right  = (cx + w / 2f).coerceIn(0f, 1f),
                bottom = (cy + h / 2f).coerceIn(0f, 1f)
            ))
        }
        return nms(candidates)
    }

    private fun nms(detections: List<DetectionResult>): List<DetectionResult> {
        val result = mutableListOf<DetectionResult>()
        detections.groupBy { it.classId }.forEach { (_, dets) ->
            val sorted = dets.sortedByDescending { it.confidence }.toMutableList()
            while (sorted.isNotEmpty()) {
                val best = sorted.removeAt(0)
                result.add(best)
                sorted.removeAll { iou(best, it) > IOU_THRESHOLD }
            }
        }
        return result
    }

    private fun iou(a: DetectionResult, b: DetectionResult): Float {
        val iL = maxOf(a.left, b.left); val iT = maxOf(a.top, b.top)
        val iR = minOf(a.right, b.right); val iB = minOf(a.bottom, b.bottom)
        val inter = maxOf(0f, iR - iL) * maxOf(0f, iB - iT)
        val aArea = (a.right - a.left) * (a.bottom - a.top)
        val bArea = (b.right - b.left) * (b.bottom - b.top)
        return inter / (aArea + bArea - inter + 1e-6f)
    }

    override fun close() = interpreter.close()
}
