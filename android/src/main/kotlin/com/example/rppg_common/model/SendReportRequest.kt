package com.rppg.net.models.sendReport


data class SendReportRequest(
    val avgBpm: Int,
    val avgO2SaturationLevel: Int,
    val avgRespirationRate: Int,
    val reportTimestamp: Long,
    val bloodPressureStatus: String,
    val stressStatus: String,
    val bloodPressure: BloodPressurePair
)

data class BloodPressurePair(val systolic: Int, val diastolic: Int)