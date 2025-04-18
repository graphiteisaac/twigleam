pub type Token {
  BlockStart
  BlockEnd
  VarStart
  VarEnd
  Text(text: String)
  Name(name: String)
  Number(number: Int)
  String(string: String)
  Operator(op: String)
  Arrow
  Spread
  Punctuation(sign: String)
  InterpolationStart
  InterpolationEnd
  EOF
}
