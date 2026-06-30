import 'dart:html' as html;

String getBrowserUrl() => html.window.location.href;

void resetWebUrl() {
  html.window.history.replaceState(null, '', '/');
}
