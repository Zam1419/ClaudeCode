import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i18n.dart';
import 'data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('lang') ?? 'en';
  runApp(KsaApp(initialLocale: Locale(langCode)));
}

class KsaApp extends StatefulWidget {
  const KsaApp({super.key, required this.initialLocale});
  final Locale initialLocale;

  @override
  State<KsaApp> createState() => _KsaAppState();

  static _KsaAppState of(BuildContext c) =>
      c.findAncestorStateOfType<_KsaAppState>()!;
}

class _KsaAppState extends State<KsaApp> {
  late Locale _locale = widget.initialLocale;

  void setLocale(Locale l) async {
    setState(() => _locale = l);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', l.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF00D68F);
    return MaterialApp(
      title: 'KSA Landed Cost',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF07090D),
        fontFamily: _locale.languageCode == 'ar' ? 'Cairo' : 'Inter',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: seed, width: 1.4),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _value = TextEditingController(text: '1000');
  final _freight = TextEditingController(text: '150');
  final _insurance = TextEditingController(text: '20');
  final _duty = TextEditingController(text: '5');
  final _clearance = TextEditingController(text: '150');

  String _category = 'general';
  String _currency = 'SAR';

  BannerAd? _banner;
  bool _bannerReady = false;

  // Google test banner ad unit. Replace with real IDs before release.
  static const _testBannerUnit = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    for (final c in [_value, _freight, _insurance, _duty, _clearance]) {
      c.addListener(() => setState(() {}));
    }
    _loadBanner();
  }

  void _loadBanner() {
    _banner = BannerAd(
      adUnitId: _testBannerUnit,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _bannerReady = true),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    for (final c in [_value, _freight, _insurance, _duty, _clearance]) {
      c.dispose();
    }
    super.dispose();
  }

  double _n(TextEditingController c) => double.tryParse(c.text) ?? 0;

  ({double cif, double duty, double vat, double clr, double total}) _calc() {
    final fx = kFx[_currency] ?? 1;
    final val = _n(_value) * fx;
    final frt = _n(_freight) * fx;
    final ins = _n(_insurance) * fx;
    final dutyRate = _n(_duty) / 100;
    final clr = _n(_clearance);
    final cif = val + frt + ins;
    final duty = cif * dutyRate;
    final vat = (cif + duty) * 0.15;
    return (cif: cif, duty: duty, vat: vat, clr: clr, total: cif + duty + vat + clr);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final t = isAr ? kAr : kEn;
    final fmt = NumberFormat.currency(
      locale: isAr ? 'ar_SA' : 'en_US',
      symbol: '﷼ ',
      decimalDigits: 2,
    );
    final r = _calc();

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF0B1A14), Color(0xFF07090D), Color(0xFF0A0820)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(title: t['brand']!, tagline: t['tagline']!),
                        const SizedBox(height: 18),
                        _Hero(title: t['heroTitle']!, sub: t['heroSub']!),
                        const SizedBox(height: 14),
                        _Card(
                          title: t['inputs']!,
                          child: Column(
                            children: [
                              _DropdownField<String>(
                                label: t['category']!,
                                value: _category,
                                items: kCategories.map((c) {
                                  final name = isAr ? c.ar : c.en;
                                  return DropdownMenuItem(
                                    value: c.key,
                                    child: Text('$name — ${c.duty}%'),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v == null) return;
                                  final c = kCategories.firstWhere((x) => x.key == v);
                                  setState(() {
                                    _category = v;
                                    _duty.text = c.duty.toString();
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(children: [
                                Expanded(child: _NumField(label: t['value']!, controller: _value)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DropdownField<String>(
                                    label: t['currency']!,
                                    value: _currency,
                                    items: kFx.keys
                                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                                        .toList(),
                                    onChanged: (v) => setState(() => _currency = v ?? 'SAR'),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                Expanded(child: _NumField(label: t['freight']!, controller: _freight)),
                                const SizedBox(width: 12),
                                Expanded(child: _NumField(label: t['insurance']!, controller: _insurance)),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                Expanded(child: _NumField(label: t['duty']!, controller: _duty)),
                                const SizedBox(width: 12),
                                Expanded(child: _NumField(label: t['clearance']!, controller: _clearance)),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Card(
                          title: t['breakdown']!,
                          trailing: _Pill(text: 'VAT 15%'),
                          child: Column(children: [
                            _Line(label: t['cif']!, value: fmt.format(r.cif)),
                            _Line(label: t['dutyAmt']!, value: fmt.format(r.duty)),
                            _Line(label: t['vatAmt']!, value: fmt.format(r.vat)),
                            _Line(label: t['clearanceAmt']!, value: fmt.format(r.clr), last: true),
                            const SizedBox(height: 14),
                            _TotalCard(label: t['totalLanded']!, sub: t['inSar']!, value: fmt.format(r.total)),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t['footer']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(.5), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_bannerReady && _banner != null)
                  SizedBox(
                    width: _banner!.size.width.toDouble(),
                    height: _banner!.size.height.toDouble(),
                    child: AdWidget(ad: _banner!),
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final next = isAr ? const Locale('en') : const Locale('ar');
            KsaApp.of(context).setLocale(next);
          },
          backgroundColor: const Color(0xFF00D68F),
          foregroundColor: const Color(0xFF04101A),
          icon: const Icon(Icons.translate),
          label: Text(isAr ? 'EN' : 'العربية'),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.tagline});
  final String title, tagline;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(colors: [Color(0xFF00D68F), Color(0xFF7C5CFF)]),
          boxShadow: [BoxShadow(color: const Color(0xFF00D68F).withOpacity(.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        alignment: Alignment.center,
        child: const Text('ك', style: TextStyle(color: Color(0xFF06121B), fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white)),
            Text(tagline, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.55))),
          ],
        ),
      ),
    ]);
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.title, required this.sub});
  final String title, sub;
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.6))),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.title, this.trailing});
  final Widget child;
  final String? title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.5), blurRadius: 60, offset: const Offset(0, 20))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(children: [
                Text(title!.toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white.withOpacity(.75))),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ]),
            ),
          child,
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 12),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({required this.label, required this.value, required this.items, required this.onChanged});
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          dropdownColor: const Color(0xFF12161E),
          value: value,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.last = false});
  final String label, value;
  final bool last;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(.08))),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(.6), fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
      ]),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.label, required this.sub, required this.value});
  final String label, sub, value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00D68F).withOpacity(.4)),
        gradient: LinearGradient(colors: [
          const Color(0xFF00D68F).withOpacity(.18),
          const Color(0xFF7C5CFF).withOpacity(.18),
        ]),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(),
                style: TextStyle(fontSize: 11, letterSpacing: .5, color: Colors.white.withOpacity(.8))),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.5))),
          ]),
        ),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF00D68F).withOpacity(.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text('VAT 15%',
          style: TextStyle(color: Color(0xFF00D68F), fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
