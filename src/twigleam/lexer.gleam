import gleam/list
import gleam/string
import splitter.{type Splitter}

pub type State {
  StateText
  StateVerbatim
  StateTag
  StateBlock
  StateComment
}

pub type Splitters {
  Splitters(
    any_start_token: Splitter,
    tag: Splitter,
    tag_end: Splitter,
    block: Splitter,
    block_end: Splitter,
    comment: Splitter,
    comment_end: Splitter,
    filter: Splitter,
  )
}

pub type Lexer {
  Lexer(
    source: String,
    state: State,
    buffer: String,
    pos: #(Int, Int),
    splitters: Splitters,
    accum: List(Token),
  )
}

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

pub type Punctuation {
  Pipe
  Period
  Comma
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
  Punctuation(sign: Punctuation)
  InterpolationStart
  InterpolationEnd
  EOF
}

pub fn new(source: String) -> Lexer {
  Lexer(
    source:,
    state: StateText,
    buffer: "",
    pos: #(0, 0),
    splitters: Splitters(
      any_start_token: splitter.new(["{{", "{%", "{#"]),
      tag: splitter.new(["{{"]),
      tag_end: splitter.new(["}}"]),
      block: splitter.new(["{%"]),
      block_end: splitter.new(["%}"]),
      comment: splitter.new(["{#"]),
      comment_end: splitter.new(["#}"]),
      filter: splitter.new(["|"]),
    ),
    accum: [],
  )
}

fn lex_tag(input: String, ctx: Lexer) -> #(String, Lexer) {
  let #(tag, _, rest) = splitter.split(ctx.splitters.tag_end, input)
  let tag = string.trim(tag)
  let #(tag, _, filter) = splitter.split(ctx.splitters.filter, tag)

  case filter {
    "" -> #(
      rest,
      Lexer(..ctx, accum: [VarEnd, Name(tag), VarStart, ..ctx.accum]),
    )
    _ -> #(
      rest,
      Lexer(..ctx, accum: [
        VarEnd,
        Name(filter),
        Punctuation(Pipe),
        Name(tag),
        VarStart,
        ..ctx.accum
      ]),
    )
  }
}

fn lex_block(input: String, ctx: Lexer) -> #(String, Lexer) {
  let #(tag, _, rest) = splitter.split(ctx.splitters.block_end, input)
  let tag = string.trim(tag)
  #(rest, Lexer(..ctx, accum: [BlockEnd, Name(tag), BlockStart, ..ctx.accum]))
}

fn next(lexer: Lexer) -> Lexer {
  echo lexer.source

  case lexer.source {
    "" -> Lexer(..lexer, source: "")
    "{{" <> rest ->
      case splitter.split(lexer.splitters.tag_end, rest) {
        #(block, "}}", rest) -> lex_tag(block, Lexer(..lexer, source: rest)).1
        _ -> Lexer(..lexer, source: rest)
      }

    "{%" <> rest ->
      case splitter.split(lexer.splitters.block_end, rest) {
        #(block, "}}", rest) -> lex_block(block, Lexer(..lexer, source: rest)).1
        _ -> Lexer(..lexer, source: rest)
      }

    "{#" <> rest -> {
      let #(comment, _, rest) =
        splitter.split(lexer.splitters.comment_end, rest)
      Lexer(..lexer, source: rest, accum: [
        CommentEnd,
        Text(comment),
        CommentStart,
        ..lexer.accum
      ])
    }

    src -> {
      let #(text, token, rest) =
        splitter.split(lexer.splitters.any_start_token, src)

      Lexer(..lexer, accum: [Text(text), ..lexer.accum], source: token <> rest)
    }
  }
}

pub fn do_lex(lexer: Lexer) -> List(Token) {
  let next = next(lexer)

  case next.source {
    "" -> list.reverse([EOF, ..lexer.accum])
    _ -> do_lex(next)
  }
}
