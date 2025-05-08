import twigleam/lexer.{type Token}

pub fn tokenise(input: String) -> List(Token) {
  lexer.new(input)
  |> lexer.do_lex
}
