package com.zeelearn.intranet

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    /// Ensure App Links / deep-link intents are delivered when the activity
    /// is reused (singleTask / warm start).
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
