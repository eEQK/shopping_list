extension Rec2Ext<A, B> on Iterable<(A, B)> {
  Iterable<R> mapR2<R>(R Function(A, B) f) => //
      map((e) => f(e.$1, e.$2));
}

extension Rec3Ext<A, B, C> on Iterable<(A, B, C)> {
  Iterable<R> mapR3<R>(R Function(A, B, C) f) =>
      map((e) => f(e.$1, e.$2, e.$3));
}
