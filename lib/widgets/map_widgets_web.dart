// Implementação WEB — só compilada quando dart.library.html está disponível.
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../models/barbershop_model.dart';

/// Registra um <iframe> do Google Maps para uso via HtmlElementView.
/// Chamado apenas no Flutter Web.
void registerMapView(String viewType, String embedUrl) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final iframe = html.IFrameElement()
      ..src = embedUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      // Tema escuro via CSS filter — integra com o design do app
      ..style.filter =
          'invert(90%) hue-rotate(180deg) saturate(0.85) brightness(0.88)'
      ..setAttribute('allowfullscreen', '')
      ..setAttribute('loading', 'lazy')
      ..setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
    return iframe;
  });
}

/// Stub na Web — o _MobileMapView nunca é usado aqui.
/// Retorna um SizedBox vazio para satisfazer a assinatura do import condicional.
Widget buildMobileMapView({
  required BarbershopModel shop,
  required double height,
  required dynamic loadState,
  required void Function(dynamic) onStateChange,
  required VoidCallback onOpenMaps,
  required Widget loadingWidget,
  required Widget offlineWidget,
}) =>
    SizedBox(height: height);
