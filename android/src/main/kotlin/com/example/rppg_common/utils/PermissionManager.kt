package com.example.rppg_common.utils

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.google.android.material.dialog.MaterialAlertDialogBuilder


class PermissionManager {

    val REQUEST_VIDEO_PERMISSIONS = 1
    val VIDEO_PERMISSIONS = arrayOf(Manifest.permission.CAMERA)

    companion object {
        private const val VIDEO_PERMISSION = "video_permisson"
    }

    fun checkVideoPermission(fragment: Fragment, callback: ()-> Unit) {
        if (hasPermissionsGranted(fragment, VIDEO_PERMISSIONS)) {
            callback.invoke()
        } else {
            requestVideoPermissions(fragment)
        }
    }

    private fun hasPermissionsGranted(fragment: Fragment, permissions: Array<String>) =
        permissions.none {
            ContextCompat.checkSelfPermission(fragment.requireContext(), it) !=
                    PackageManager.PERMISSION_GRANTED
        }

    private fun requestVideoPermissions(fragment: Fragment) {
        if (shouldShowRequestPermissionRationale(fragment, VIDEO_PERMISSIONS)) {
            MaterialAlertDialogBuilder(fragment.context)
                .setMessage(fragment.requireContext().getString(R.string.need_camera_permission))
                .setPositiveButton(android.R.string.ok) { _, _ ->
                    fragment.requestPermissions(VIDEO_PERMISSIONS, REQUEST_VIDEO_PERMISSIONS)
                }
                .setNegativeButton(android.R.string.cancel) { _,_ ->
                    fragment.activity?.finish()
                }


            ConfirmationDialog().show(fragment.childFragmentManager, VIDEO_PERMISSION)
        } else {
            fragment.requestPermissions(VIDEO_PERMISSIONS, REQUEST_VIDEO_PERMISSIONS)
        }
    }

    private fun shouldShowRequestPermissionRationale(
        fragment: Fragment,
        permissions: Array<String>
    ) = permissions.any { fragment.shouldShowRequestPermissionRationale(it) }

    fun onRequestPermissionsResult(
        fragment: Fragment,
        requestCode: Int, permissions: Array<String>,
        grantResults: IntArray, callback: ()-> Unit
    ) {
        if (requestCode == REQUEST_VIDEO_PERMISSIONS) {
            if (grantResults.size == VIDEO_PERMISSIONS.size) {
                for (result in grantResults) {
                    if (result != PackageManager.PERMISSION_GRANTED) {
                        ErrorDialog.newInstance(fragment.requireContext().getString(R.string.permission_request))
                            .show(fragment.childFragmentManager, VIDEO_PERMISSION)
                        break
                    } else {
                        callback.invoke()

                    }
                }
            } else {
                ErrorDialog.newInstance(fragment.requireContext().getString(R.string.permission_request))
                    .show(fragment.childFragmentManager, VIDEO_PERMISSION)
            }
        } else {
            fragment.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }

    private fun isPermissionGranted(context: Context, permission: String?) =
        ContextCompat.checkSelfPermission(
            context,
            permission!!
        ) == PackageManager.PERMISSION_GRANTED
}