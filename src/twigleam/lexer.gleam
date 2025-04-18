pub type Operator {
  Equals
  Or
  And
  BOr
  BXor
  BAnd
  IsEqual
  NotEqual
  LessThan
  LTE
  GreaterThan
  GTE
  Not
  In
  NotIn
  Matches
  StartsWith
  EndsWith
  DotDot
  // What is this?
  Plus
  Minus
  Concat
  Multiply
  Divide
  DoubleSlash
  Modulo
  DoubleAsterisk
  DoubleQuestion
}

pub type Token {
  BlockStart
  BlockEnd
  VarStart
  VarEnd
  CommentStart
  CommentEnd
  Text(text: String)
  Name(name: String)
  Number(number: Int)
  String(string: String)
  Operator(op: Operator)
  Arrow
  Spread
  Punctuation(sign: String)
  InterpolationStart
  InterpolationEnd
  EOF
}
