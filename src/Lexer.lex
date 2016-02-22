import java_cup.runtime.*;
import java.util.regex.Pattern;
import java.util.*;

%%
%class Lexer
%unicode
%cup
%line
%column

%{
	StringBuffer string = new StringBuffer();

	Map dictionary = new HashMap();
	int keyType, valueType;

	private Symbol symbol(int type) {
        return new Symbol(type, yyline, yycolumn);
    }
    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }

    private void setKeyType(int type) {
    	keyType = type;
    }

    private void setValueType(int type) {
    	ValueType = type;
    }

    private void addToDictionary()
%}

/* Begin working on Macro Statement */

/* some basic regex */
EndOfLine = \r\n|\n|\r
ValidChar = [^\r\n]
Letter = [a-zA-Z]
Digit = [0-9]
IdChar = {Letter} | {Digit} | "_"
WhiteSpace = \r|\n|\r\n|" "|"\t"

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment}
EndOfLineComment = "#"{ValidChar}*{EndOfLine}?
TraditionalComment = "/#" [^#]* "#/" | "/#" [#]+ "/"

/* identifier */
Identifier = {Letter}{IdChar}*

/* character */
Character = {Letter} | \p{Punct} | "'" {Digit} "'"


/* numbers */
Integer = [-]?{Digit}+
Rational = {Integer}"_"{Digit}+"/"{Digit}+ | {Integer}"/"{Digit}+
Float = {Integer}"\."{Integer}

/* dictionary */
ValidType = {Interger} | {Character} | {Rational} | {Float}
DictionaryItem = {ValidType} ":" {ValidType} 



%%
<YYINITIAL> {
	/* keywords */

		/* data type */
		"char" {return symbol(sym.CHAR);}
		"bool" {return symbol(sym.BOOLEAN);}
		"int"  {return symbol(sym.INTEGER);}
		"rat"  {return symbol(sym.RATIONAL);}
		"float"{return symbol(sym.FLOAT);}

		"dict" {dictionary.clear(); yybegin(DICTIONARY); return symbol(sym.DICTIONARY);}
		"seq"  {yybegin(SEQUENCE);}

		/* declaration */
		"tdef" {return symbol(sym.TYPEDEF);}
		"fdef" {return symbol(sym.FUNCTIONDEF);}
		"alias"{return symbol(sym.ALIAS);}
		"void" {return symbol(sym.VOID);}

		/* statement */
		"var"   {return symbol(sym.VARI);}
		"if"    {return symbol(sym.IF);}
		"fi"    {return symbol(sym.ENDIF);}
		"else"  {return symbol(sym.ELSE);}
		"elif"  {return symbol(sym.ELSEIF);}
		"then"  {return symbol(sym.THEN);}
		"while" {return symbol(sym.WHILE);}
		"forall"{return symbol(sym.FORALL);}
		"return"{return symbol(sym.RETURN);}
		"read"  {return symbol(sym.READ);}
		"print" {return symbol(sym.PRINT);}
		"do"    {return symbol(sym.DO);}
		"od"    {return symbol(sym.ENDDO);}
		"in"    {return symbol(sym.IN);}
		"main"  {return symbol(sym.MAIN);}

		/* boolean */
		"T" {return symbol(sym.TRUE);}
		"F" {return symbol(sym.FALSE);}

	/* punctuation */
	"(" {return (sym.LPAREN);}
	")" {return (sym.RPAREN);}
	"{" {return (sym.LBRACE);}
	"}" {return (sym.RBRACE);}
	"[" {return (sym.LBRACK);}
	"]" {return (sym.RBRACK);}
	";" {return (sym.SEMICOLON);}
	"," {return (sym.COMMA);}
	"." {return (sym.DOT);}

	/* operator */
	"+" {return symbol(sym.PLUS);}
	"-" {return symbol(sym.MINUS);}
	"*" {return symbol(sym.TIMES);}
	"/" {return symbol(sym.DIVIDE);}
	"=" {return symbol(sym.EQ);}
	"=="{return symbol(sym.EQEQ);}
	"!="{return symbol(sym.NOTEQUAL);}
	">" {return symbol(sym.GREATER);}
	"<" {return symbol(sym.LESS);}
	"&" {return symbol(sym.AND);}
	"|" {return symbol(sym.OR);}
	"&&"{return symbol(sym.ANDAND);}
	"||"{return symbol(sym.OROR);}
	":" {return symbol(sym.CONCATENATION);}


	/* comment */
	{Comment} { /* ignore */ }
	/* whitespace */
	{WhiteSpace} { /* ignore */ }

	/* identifier */
	{Identifier} {return symbol(sym.IDENTIFIER, yytext());}

	/* number */
	{Integer}    {return symbol(sym.INTEGER_LITERAL, new Integer(yytext()));}
	{Rational}   {return symbol(sym.RATIONAL_LITERAL);} /* turn into a double? */
	{Float}      {return symbol(sym.FLOAT_LITERAL, new Float(yytext()));}

	/* character */
	{Character}  {return symbol(sym.CHARACTER_LITERAL, yytext().charAt(0));}

	/* string */
	\"           {string.setLength(0); yybegin(STRING);}


}

<STRING> {
	\"   			{yybegin(YYINITIAL); 
					return symbol(sym.STRING_LITERAL, 
					string.toString());}
	
	[^\n\r\"\\]+ 	{string.append(yytext());}

	"\\t"			{string.append('\t');}
	"\\n"			{string.append('\n');}
	"\\r"			{string.append('\r');}
	"\\\""          {string.append('\"');}
    "\\"            {string.append('\\');}
}

<DICTIONARY> {
	"<"    {return symbol(sym.LANGLEBRACKT);}
	">"	   {yybegin(YYINITIAL); return symbol(sym.RANGLEBRACKT);}


	"char" {return symbol(sym.CHAR);}
	"int"  {return symbol(sym.INTEGER);}
	"rat"  {return symbol(sym.RATIONAL);}
	"float"{return symbol(sym.FLOAT);}
	"top"  {return symbol(sym.TOP);}


	{WhiteSpace} { /* ignore */ }
	
}


<SEQUENCE> {
	
}


[^]  {
  System.out.println("file:" + (yyline+1) +
    ":0: Error: Invalid input '" + yytext()+"'");
  return symbol(sym.BADCHAR);
}


