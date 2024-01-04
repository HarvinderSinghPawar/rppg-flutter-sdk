package com.example.rppg_common.utils

import android.app.AlertDialog
import android.content.Context
import android.content.DialogInterface



object Dialogs {

    fun OkButtonAlertPopUp(
        context: Context, title: String, message: String, okButtonText: String,
        listner: OkButtonPopUpInterface
    ) {
        try {
            val builder: AlertDialog.Builder = AlertDialog.Builder(context)
            builder.setTitle(title)
            builder.setMessage(message)
            builder.setPositiveButton(okButtonText,
                DialogInterface.OnClickListener { dialog, which ->
                    dialog.dismiss()
                    listner.onClickOkButton()
                })
            val alert: AlertDialog = builder.create()
            alert.show()

        } catch (ex: Exception) {
            val sd = ""
        }
    }

    fun TwoButtonAlertPopUp(
        context: Context, title: String, message: String, firstButtonText: String,
        secondButtonText: String, listner: TwoButtonPopUpInterface
    ) {
        try {
            val builder: AlertDialog.Builder = AlertDialog.Builder(context)


            if (title.isNotEmpty()) {
                builder.setTitle(title)
            }


            builder.setMessage(message)
            builder.setPositiveButton(firstButtonText,
                DialogInterface.OnClickListener { dialog, which ->
                    dialog.dismiss()
                    listner.onClickFirstButton()
                })
            builder.setNegativeButton(secondButtonText,
                DialogInterface.OnClickListener { dialog, which ->
                    dialog.dismiss()
                    listner.onClickSecondButton()
                })
            val alert: AlertDialog = builder.create()
            alert.show()

        } catch (ex: Exception) {
            val sd = ""
        }
    }

    interface OkButtonPopUpInterface {
        fun onClickOkButton()
    }

    interface TwoButtonPopUpInterface {
        fun onClickFirstButton()
        fun onClickSecondButton()
    }
}