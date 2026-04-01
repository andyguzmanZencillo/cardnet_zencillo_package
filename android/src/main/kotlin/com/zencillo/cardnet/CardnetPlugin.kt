package com.zencillo.cardnet

import android.app.Activity
import android.content.*
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.zencillo.cardnet.models.ModelPay
import com.zencillo.cardnet.models.ResponsePay
import org.json.JSONObject

class CardNetPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var context: Context? = null

    private var pendingResult: MethodChannel.Result? = null
    private var modelPay = ModelPay()

    private val ACTION_REQUEST = "com.necomplus.tpv.transaction.REQUEST"
    private val ACTION_RESPONSE = "com.necomplus.tpv.transaction.RESPONSE"

    private val PARAM_REQ_TYPE = "$ACTION_REQUEST.paramsTYPE"
    private val PARAM_REQ_AMOUNT = "$ACTION_REQUEST.paramsAMOUNT"
    private val PARAM_REQ_ITBIS = "$ACTION_REQUEST.paramsITBIS"
    private val PARAM_REQ_REFERENCE = "$ACTION_REQUEST.paramsREFERENCE"

    private val PARAM_RES_CODE = "$ACTION_RESPONSE.paramsCODE"
    private val PARAM_RES_MESSAGE = "$ACTION_RESPONSE.paramsMESSAGE"
    private val PARAM_RES_DATA = "$ACTION_RESPONSE.paramsDATA"

    private var receiverRegistered = false

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "cardnet")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        if (receiverRegistered) {
            context?.unregisterReceiver(receiver)
        }
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pay" -> {
                pendingResult = result

                modelPay.rAmount = call.argument<Double>("amount")!!
                modelPay.rTax = call.argument<Double>("tax")!!
                modelPay.nIdInvoice = call.argument<Int>("invoice")!!

                startReceiver()
                sendSale()
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() { activity = null }
    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?, intent: Intent?) {
            Log.d("CARDNET", "Respuesta recibida desde el datáfono")

            if (intent == null || intent.extras == null) {
                sendError("Respuesta vacía del datáfono")
                return
            }

            val code = intent.getIntExtra(PARAM_RES_CODE, -1)
            val message = intent.getStringExtra(PARAM_RES_MESSAGE) ?: ""
            val data = intent.getStringExtra(PARAM_RES_DATA) ?: ""

            handleResponse(code, message, data)
        }
    }

    private fun startReceiver() {
        if (!receiverRegistered) {
            val filter = IntentFilter(ACTION_RESPONSE)
            context?.registerReceiver(receiver, filter)
            receiverRegistered = true
            Log.d("CARDNET", "Receiver Registrado")
        }
    }

    private fun sendSale() {
        val intent = Intent(ACTION_REQUEST)
        intent.setPackage("com.necomplus.tpv")

        intent.putExtra(PARAM_REQ_AMOUNT, modelPay.rAmount)
        intent.putExtra(PARAM_REQ_ITBIS, modelPay.rTax)
        intent.putExtra(PARAM_REQ_TYPE, "SALE")
        intent.putExtra(PARAM_REQ_REFERENCE, modelPay.nIdInvoice.toString())

        context?.sendBroadcast(intent)

        Log.d("CARDNET", "Transacción enviada al datáfono")
    }

    private fun handleResponse(code: Int, message: String, data: String) {
        if (pendingResult == null) return

        try {
            if (code == 0) {
                val obj = JSONObject(data)
                val response = ResponsePay(modelPay)

                response.responseCode = code.toString()
                response.message = message
                response.autorizationCode = obj.optString("systemAuthCode", "")
                response.value = obj.optString("amount", "")
                response.tax = obj.optString("itbs", "")
                response.rrn = obj.optString("systemRrn", "")
                response.receipt = obj.optString("systemAuthCode", "")
                response.terminalId = obj.optString("terminalId", "")
                response.timeDate = obj.optString("dateTx", "") + " " + obj.optString("hourTx", "")
                response.lastFourDigitsCard = obj.optString("panMasked", "")
                response.franchise = obj.optString("typeFranchieseLabel", "")
                response.accountType = obj.optString("appLabel", "")
                response.merchantPosId = obj.optString("merchantId", "")

                val resultJson = JSONObject().apply {
                    put("code", 0)
                    put("message", "Pago exitoso")
                    put("data", JSONObject(response.toMap()))
                }

                pendingResult?.success(resultJson.toString())
            } else {
                sendError(message)
            }
        } catch (e: Exception) {
            sendError("Error procesando respuesta: ${e.message}")
        } finally {
            pendingResult = null
        }
    }

    private fun sendError(msg: String) {
        val errorJson = JSONObject().apply {
            put("code", 1)
            put("message", msg)
        }
        pendingResult?.success(errorJson.toString())
        pendingResult = null
    }
}
