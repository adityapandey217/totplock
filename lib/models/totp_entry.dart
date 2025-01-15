class TotpEntry {
  final String totpUri;
  final String secret;
  final String name;
  final String issuer;
  int remainingTime;

  TotpEntry(
      {required this.totpUri,
      required this.secret,
      this.remainingTime = 30,
      this.name = '',
      this.issuer = ''});
}