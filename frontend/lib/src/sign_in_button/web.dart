import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

import 'stub.dart';

Widget buildSignInButton({HandleSignInFn? onPressed}) {
  return web.renderButton();
}
