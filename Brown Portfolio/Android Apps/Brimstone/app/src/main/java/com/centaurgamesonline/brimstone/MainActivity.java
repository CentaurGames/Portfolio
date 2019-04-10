package com.centaurgamesonline.brimstone;

import android.content.Intent;
import android.graphics.Color;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.JsonReader;
import android.util.JsonToken;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.ValueCallback;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.anjlab.android.iab.v3.BillingProcessor;
import com.anjlab.android.iab.v3.TransactionDetails;
import com.evgenii.jsevaluator.JsEvaluator;
import com.evgenii.jsevaluator.interfaces.JsCallback;

import java.io.IOException;
import java.io.StringReader;
import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends AppCompatActivity implements BillingProcessor.IBillingHandler {
    String purchaseID = "super_ankh";
    //String purchaseID = "android.test.purchased";
    BillingProcessor bp;
    WebView myWebView;
    JsEvaluator jsEvaluator = new JsEvaluator(this);
    Timer myTimer = new Timer();

    public void makePurchase() {
        myWebView.post(new Runnable() {
            public void run() {
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
                    myWebView.evaluateJavascript("purchaseGame();", null);
                } else {
                    myWebView.loadUrl("javascript:purchaseGame();");
                }
            }
        });
    }

    public void closePurchase() {
        myWebView.post(new Runnable() {
            public void run() {
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
                    myWebView.evaluateJavascript("closeStoreKit();", null);
                } else {
                    myWebView.loadUrl("javascript:closeStoreKit();");
                }
            }
        });
    }

    public void openPurchase() {
        bp.purchase(MainActivity.this,purchaseID);
        closePurchase();
    }

    public void checkForPurchase() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            myWebView.post(new Runnable() {
                public void run() {
                    myWebView.evaluateJavascript("isStoreKitOpen();", new ValueCallback<String>() {
                        @Override
                        public void onReceiveValue(String value) {
                            JsonReader reader = new JsonReader(new StringReader(value));
                            // Must set lenient to parse single values
                            reader.setLenient(true);
                            try {
                                if (reader.peek() != JsonToken.NULL) {
                                    if (reader.peek() == JsonToken.STRING) {
                                        String msg = reader.nextString();
                                        if (msg.equals("true"))
                                            openPurchase();
                                    }
                                }
                            } catch (IOException e) {
                                Log.e("TAG", "MainActivity: IOException", e);
                            }
                        }
                    });
                }
            });
        } else {
            jsEvaluator.evaluate("isStoreKitOpen();", new JsCallback() {
                @Override
                public void onResult(String result) {
                    // Process result here.
                    // This method is called in the UI thread.
                    if (result.equals("true")) {
                        openPurchase();
                    }
                }

                @Override
                public void onError(String errorMessage) {
                    // Process JavaScript error here.
                    // This method is called in the UI thread.
                    Log.i("WARNING!", errorMessage);
                }
            });
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        bp = new BillingProcessor(this,"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtltAK4QnrjrcSSm/QuBh8DIg0Ym5MTXSdeARRU76LZopW2hOsusykvSrtBErgcQSUVMkrL9H+mJuCmQn1gDrIYD1t8dpWl5s7+0hqGn8XFleKyHYJUktvD/CZw2jr1UXmxOl48t2dmTzwBaol6tQB41AU4dc5MPFl6NcUYYM3ZXk1XT/8W4PYgosKGHAcN4py/DCO4F6usc7QeLYm18B+st8VtGFg8+xI6ncBm+1mKDOQ/Afq0quvV0W1gsbaRjeAZqhkW9VwwXHMmuel9gSuy/Z5yxDVWLfSEuLtWQUoFiRTAMrEO9z92rNrQOQwhYPDqFqN/f2BiGrbm7UIoQhgwIDAQAB",this);
        bp.initialize();
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getSupportActionBar().hide();
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        //setContentView(R.layout.activity_main);
        myWebView = new WebView(MainActivity.this);
        myWebView.setBackgroundColor(Color.BLACK);
        WebSettings webSettings = myWebView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        setContentView(myWebView);
        myWebView.loadUrl("file:///android_asset/index.html");
        myTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                checkForPurchase();
            }
        },0,1000);
    }

    @Override
    public void onProductPurchased(@NonNull String productId, @Nullable TransactionDetails details) {
        makePurchase();
        closePurchase();
        bp.consumePurchase(purchaseID);
    }

    @Override
    public void onPurchaseHistoryRestored() {
        closePurchase();
    }

    @Override
    public void onBillingError(int errorCode, @Nullable Throwable error) {
        closePurchase();
    }

    @Override
    public void onBillingInitialized() {
        closePurchase();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (!bp.handleActivityResult(requestCode, resultCode, data)) {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }

    @Override
    public void onDestroy() {
        if (bp != null) {
            bp.release();
        }
        super.onDestroy();
    }
}


