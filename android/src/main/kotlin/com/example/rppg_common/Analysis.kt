package com.example.rppg_common

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import android.view.ViewGroup
import android.widget.Toast
import androidx.exifinterface.media.ExifInterface
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.rppg.library.common.RppgCoreManager
import com.rppg.library.common.camera.CameraConfig
import com.rppg.library.common.camera.FaceData
import com.rppg.library.common.camera.RppgCameraManager
import com.rppg.library.common.socket.AuthorizationException
import com.rppg.library.common.socket.RppgTypedSocketManager
import com.rppg.library.common.socket.model.AccessToken
import com.rppg.library.common.socket.model.BloodPressure
import com.rppg.library.common.socket.model.BloodPressureStatus
import com.rppg.library.common.socket.model.HrvMetrics
import com.rppg.library.common.socket.model.MeasurementMeanData
import com.rppg.library.common.socket.model.MeasurementProgress
import com.rppg.library.common.socket.model.MeasurementSignal
import com.rppg.library.common.socket.model.MeasurementStatus
import com.rppg.library.common.socket.model.MessageStatus
import com.rppg.library.common.socket.model.MovingWarning
import com.rppg.library.common.socket.model.SendingRateWarning
import com.rppg.library.common.socket.model.SocketMessage
import com.rppg.library.common.socket.model.StressStatus
import com.rppg.library.common.socket.model.UnknownType
import com.rppg.library.core.RppgCore
import com.rppg.net.models.sendReport.BloodPressurePair
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onEach
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date

class Analysis {

    companion object {
        @Volatile
        private var instance: Analysis? = null

        fun getInstance(): Analysis {
            if (instance == null) {
                synchronized(this) {
                    if (instance == null) {
                        instance = Analysis()
                    }
                }
            }
            return instance!!
        }
    }

    ///Fragment
    private lateinit var permissionManager: PermissionManager
    private lateinit var cameraManager: RppgCameraManager
    private var isFrontCamera = true
    var viewGroup: ViewGroup? = null
    var SdNn: String = ""

    ///Fragment

//    fun setupFacade() {
//
//    }



    init {
        setupFacade()
        setupPermission()
    }

    private fun setupFacade() {
        cameraManager = RppgCameraManager.Builder(
            lifecycleOwner = this,
            camera = cameraView,
            cameraConfig = CameraConfig(isDebug = BuildConfig.DEBUG, isFrontCamera = isFrontCamera)
        ).buildFlow { dataFlow ->
            // camera
            lifecycleScope.launch(Dispatchers.IO) {
                dataFlow.collect { data ->
                    val succeed = data.floatArray.isNotEmpty()
                    handleGaps(succeed)
                    if (succeed) getVM().sendFaceData(data)
                }
            }
        }
    }

    private fun setupPermission() {

    }

    private val socketManager = RppgTypedSocketManager()
    private var pointer = 0L
    private val _qualityTextData = MutableLiveData<String>()

    var finalUrl = ""
    private val dialogMessageEvent = MutableLiveData<String>()

    private val coreManager = RppgCoreManager().apply {
        pointer = init(fps = 30, mode = RppgCore.CalculationMode.BGR.mode)
    }

    var rpm = 0
    var bpm = 0
    var oxy = 0
    var stressLevel = ""
    var stressStatus = StressStatus.UNKNOWN
    var blood = ""
    var bloodPressureStatus = BloodPressureStatus.UNKNOWN
    var bpp = BloodPressurePair(0, 0)
    var afibRiskValue = ""
    var sdnns: Double = 0.0
    var progress = 0
    var canStartTimerValue = false

    private val socketOpened = MutableStateFlow<Flow<SocketMessage>?>(null)

    private val messagesFlow = socketOpened.flatMapLatest {
        it ?: emptyFlow()
    }
        // TODO: 3/19/21 replace switching to another flows
        .onEach { data ->
            invoke(data)
        }
        .flowOn(Dispatchers.Main)
        .catch {
            Log.d("rrrrr", "got it")
            var dr = ""
            //tokenExpired.postValue(true)

            signIn(
                SavedData.getPreferences(app.appContext, "email"),
                SavedData.getPreferences(app.appContext, "password")
            )

        }
    //.onErrorReturn(this)

    protected var successEvent = MutableLiveData<Boolean>()


    fun successEventListener(): LiveData<Boolean> {
        return successEvent
    }

    private val bpmEventData = MutableLiveData<MeasurementMeanData>()
    private val bpEventData = MutableLiveData<BloodPressure>()
    private val bpmEventMessage: LiveData<String> = messagesFlow
        .filter { it is UnknownType || it is MeasurementStatus }
        .map { data ->
            when (data) {
                is MeasurementStatus -> data.toMessage()

                else -> null
            }
        }
        .onEach {
            Log.d("TestTAG", "bpmEventMessage: $it")
        }
        .filterNotNull()
        .asLiveData(Dispatchers.IO)

    private val rateWarningMessage = MutableLiveData<String>()
    private val movingWarningMessage = MutableLiveData<String>()
    private val signalEventMessage = MutableLiveData<List<Entry>>()
    private val timerEvent = MutableLiveData<Boolean>()
    private val canMakeAnalyze = MutableLiveData<Boolean>()
    private val successEventMessage = MutableLiveData<Boolean>()
    private var socketJob: Job? = null
    private val sdnnData = MutableLiveData<Double>()
    fun getRateSDNNData(): LiveData<Double> = sdnnData


    private val coroutineExceptionHandler =
        CoroutineExceptionHandler { coroutineContext, throwable ->
            when (throwable) {
                is AuthorizationException -> tokenExpired.postValue(true)
                else -> showError(throwable.message ?: "")
            }
        }

    init {
        Log.d("RPPG", " version ${RppgCoreManager().getVersion()}")
    }

    fun stopSocket() {
//        socket.destroy()

        socketManager.stopSocket()
        canStartTimerValue = false
    }


    fun sendImage(localBitmap: Bitmap?, timestamp: Long) {
//        scope.launch(Dispatchers.IO) {
//
//            val file: File = File.createTempFile("tmp", "jpeg", app.appContext.cacheDir)
//            val bos = FileOutputStream(file)
//
//            localBitmap?.compress(Bitmap.CompressFormat.JPEG, 90, bos)
//
//            setExifTimestamp(file, timestamp)
//
//            val bytes = ByteArray(file.length().toInt())
//            try {
//                val bis = BufferedInputStream(FileInputStream(file))
//                bis.read(bytes, 0, bytes.size)
//                bis.close()
//            } catch (e: FileNotFoundException) {
//                Log.e("ImageProcess", "File reading failure: $e")
//            } catch (e: IOException) {
//                Log.e("ImageProcess", "IO failure: $e")
//            }
//            socket.sendImage(bytes)
//            bos.flush()
//            bos.close()
//            localBitmap?.recycle()
//        }
    }

    /*  private val userEvent = MutableLiveData<UserEntity>()

      fun getUser() {
          scope.launch {
              val email = getDB().userAuthDao().getUser().email
              userEvent.postValue(getDB().userDao().fetchUserByEmail(email).first())
          }
      }
      fun getUserEvent(): LiveData<UserEntity> = userEvent*/
    fun sendFaceData(data: FaceData) {
        scope.launch(Dispatchers.IO) {
            with(data) {
                val result = coreManager.track(width, height, byteArray, timestamp, floatArray)
                Log.d("TestTAG", "sendFaceData: $result")
                socketManager.update(result, timestamp)
            }
        }
    }


    private fun setExifTimestamp(file: File, timestamp: Long) {
        val date = Date(timestamp)
        val time = SimpleDateFormat("yyyy:MM:dd HH:mm:ss").format(date)
        val millis = SimpleDateFormat("SSS").format(date)

        val exifInterface = ExifInterface(file)
        exifInterface.setAttribute(ExifInterface.TAG_DATETIME_ORIGINAL, time)
        exifInterface.setAttribute(ExifInterface.TAG_SUBSEC_TIME_ORIGINAL, millis)
        exifInterface.saveAttributes()
    }

    fun openSocket(context: Context) {
        /*  getDB.userDao().fetchUserByEmail(getPrefs().userEmail)*/
        var gender = ""
        if (AppPreferenceClass.getInstance(context).gender.equals("F")) {
            gender = "female"
        } else {
            gender = "male"
        }
        var urlSocket = BuildConfig.SOCKET_URL + "vp/bgr_signal_socket"
        finalUrl =
            urlSocket + "?" + "authToken=" + getPrefs().authToken + "&" + "fps=" + "30" + "&" + "age=" + AppPreferenceClass.getInstance(
                context
            ).age + "&" + "sex=" + gender + "&" + "height=" + AppPreferenceClass.getInstance(context).height + "&" + "weight=" + AppPreferenceClass.getInstance(
                context
            ).weight
        Log.d("gopiTag", "openSocket")


        var v = socketManager.startSocket(
            token = getPrefs().authToken,
            url = urlSocket
        )

        socketOpened.value = v
        Log.d("MySocketUrl - ", urlSocket)


        //socketOpened.onErrorReturn(object:)
//        socketJob?.cancel()
//        socketJob = viewModelScope.launch(Dispatchers.IO) {
//            socket.connect().collect { message ->
//
//            }
//        }
    }

    override fun onCleared() {
        super.onCleared()
        Log.d("gopiTag", "stopSocket")

        socketManager.stopSocket()
    }

    private fun showVitalData(vital: MeasurementMeanData) {
        vital?.let {
            bpm = it.bpm
            rpm = it.rr
            oxy = it.oxygen
            stressLevel = it.stressStatus?.name ?: ""
            stressStatus = it.stressStatus ?: StressStatus.UNKNOWN
            blood = it.bloodPressureStatus?.name ?: ""

            bloodPressureStatus = it.bloodPressureStatus ?: BloodPressureStatus.UNKNOWN
            bpmEventData.postValue(it)
        }
    }

    private fun showBpData(bp: BloodPressure) {
        blood = "" + bp.systolic + "/" + bp.diastolic
        bpp = BloodPressurePair(bp.systolic, bp.diastolic)
        bpEventData.postValue(bp)
    }


    private fun showSignalData(signal: MeasurementSignal?) {
        signal?.let { measurementSignal ->
            if (measurementSignal.signal.isEmpty()) {
                return
            }

            val signalsNeeded = 256

            val signals: List<Float> = if (measurementSignal.signal.count() < signalsNeeded) {
                val originalSignals = measurementSignal.signal.map { it.toFloat() }
                val signalsToBeAdded = signalsNeeded - measurementSignal.signal.size
                val filterSignal = originalSignals.first()
                val modifiedSignals = mutableListOf<Float>().apply {
                    repeat(signalsToBeAdded) {
                        add(filterSignal)
                    }
                }
                modifiedSignals.addAll(originalSignals)
                modifiedSignals
            } else {
                measurementSignal.signal.map { it.toFloat() }
            }

            val entries = signals.mapIndexed { index, value ->
                Entry(index.toFloat(), value)
            }

            signalEventMessage.postValue(entries)
        }
    }

    private fun MeasurementStatus.toMessage(): String {
        val percentage = if (progress <= 100) " $progress%" else ""
        Log.d("gopiTag", statusCode.toString())


        return when (statusCode) {
            MessageStatus.SUCCESS -> {
                allowTimer()
                app.appContext.getString(R.string.socket_status_success)
            }
            MessageStatus.NO_FACE -> "No Face Detected"
            MessageStatus.FACE_LOST -> app.appContext.getString(R.string.socket_status_face_lost)
            MessageStatus.CALIBRATING -> {
                app.appContext.getString(R.string.socket_status_calibrating) //+ percentage
            }
            MessageStatus.RECALIBRATING -> app.appContext.getString(R.string.socket_status_recalibrating) + percentage
            /* MessageStatus.RECALIBRATING -> percentage*/
            MessageStatus.BRIGHT_LIGHT_ISSUE -> app.appContext.getString(R.string.socket_status_bright_noise)
            MessageStatus.NOISE_DURING_EXECUTION -> app.appContext.getString(R.string.socket_status_noise)/*" 100%"*/

            else -> ""
        }
    }

//    private fun showStatusData(status: MeasurementStatus?) {
//        status?.let {
//
//            val message = it.toMessage()
//            showStatus(message)
//        }
//    }

    private fun allowTimer() {
        if (!canStartTimerValue) {
            successEventMessage.postValue(true)
            canStartTimerValue = true
        }
    }

//    private fun showStatus(message: String) {
//        bpmEventMessage.postValue(message)
//    }

    private fun showProgressData(progress: MeasurementProgress?) {
        progress?.let {
            this.progress = it.progressPercent
        }
    }

    private var timerDelay = 0L
    private val fiveSec = 5 * 1000
    private fun showRateWarningData(warning: SendingRateWarning?) {
        warning?.let {
            if (warning.delayValue > 200 && System.currentTimeMillis() - timerDelay > fiveSec) {
                timerDelay = System.currentTimeMillis()
                rateWarningMessage.postValue(warning.notificationMessage!!)
            }
        }
    }

    private fun showMovingWarning(warning: MovingWarning?) {
        warning?.let {
            movingWarningMessage.postValue(app.appContext.getString(R.string.moving_detected_stay_still))
        }
    }

    private fun showError(error: String) {
        getDialogEvent().postValue(error)
        timerEvent.postValue(true)
        socketManager.stopSocket()
    }

    private fun authFail() {
        timerEvent.postValue(true)
        socketManager.stopSocket()
        tokenExpired.postValue(true)
    }

    fun getBpmEvent(): LiveData<MeasurementMeanData> = bpmEventData
    fun getBpEvent(): LiveData<BloodPressure> = bpEventData
    fun getSocketMessage(): LiveData<String> = bpmEventMessage
    fun getRateWarningMessage(): LiveData<String> = rateWarningMessage
    fun getSignalMessage(): LiveData<List<Entry>> = signalEventMessage
    fun getTimerEvent(): LiveData<Boolean> = timerEvent


    //    fun getAnalyzeEvent(): LiveData<Boolean> = canMakeAnalyze
    fun getSuccessEvent(): LiveData<Boolean> = successEventMessage

    private fun invoke(message: SocketMessage) {
        Log.d("gopiTag", message.toString())

        when (message) {
            is MeasurementMeanData -> showVitalData(message)
            is MeasurementSignal -> showSignalData(message)
            //  is MeasurementStatus -> {
            //        showStatusData(message)
            //   }
            is BloodPressure -> showBpData(message)
            is MeasurementProgress -> showProgressData(message)
            is SendingRateWarning -> showRateWarningData(message)
            is MovingWarning -> showMovingWarning(message)
            is AccessToken -> storeAccessToken(message)
            is HrvMetrics -> getSDNN(message)


            else -> {

//                showStatus(message)
            }
        }
    }

    private fun getSDNN(sdnn: HrvMetrics) {

        sdnns = sdnn.sdnn

        Log.d("SDDNN", sdnns.toString())
        sdnn?.let {
            sdnnData.postValue(it.sdnn)
        }

    }


    private fun storeAccessToken(tokenData: AccessToken?) {
        Log.d("TOKEN", "token is $tokenData")
    }

//    external fun getVersion(): String
//
//    external fun createNativeInstance(fps: Int, mode: Int): Long
//
//    external fun track(
//        nativePointer: Long,
//        width: Int,
//        height: Int,
//        data: ByteArray,
//        imageTimestamp: Long,
//        list: FloatArray
//    ): DoubleArray





}