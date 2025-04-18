import gleeunit
import gleeunit/should
import twigleam
import twigleam/lexer

pub fn main() {
  gleeunit.main()
}

pub fn lex_trivial_text_test() {
  "Hello!"
  |> twigleam.tokenise
  |> should.equal([lexer.Text("Hello!"), lexer.EOF])
}

pub fn lex_tag_test() {
  "Hello {{ name }}"
  |> twigleam.tokenise
  |> should.equal([
    lexer.Text("Hello "),
    lexer.VarStart,
    lexer.Name("name"),
    lexer.VarEnd,
    lexer.EOF,
  ])
}
