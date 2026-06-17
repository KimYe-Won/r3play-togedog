package com.test.tflitetest

data class DetectionResult(
    val classId: Int,
    val className: String,
    val confidence: Float,
    val left: Float,   // normalized [0,1]
    val top: Float,
    val right: Float,
    val bottom: Float
)
