/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Dont remove anything that was here initially
 */

%option noyywrap 
%{
    #include <cool-parse.h>
    #include <stringtab.h>
    #include <utilities.h>

    /* The compiler assumes these identifiers. */
    #define yylval cool_yylval
    #define yylex  cool_yylex

    /* Max size of string constants */
    #define MAX_STR_CONST 1025
    #define YY_NO_UNPUT   /* keep g++ happy */

    extern FILE *fin; /* we read from this file */

    /* define YY_INPUT so we read from the FILE fin:
    * This change makes it possible to use this scanner in
    * the Cool compiler.
    */
    #undef YY_INPUT
    #define YY_INPUT(buf,result,max_size) \
        if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
            YY_FATAL_ERROR( "read() in flex scanner failed");

    char string_buf[MAX_STR_CONST]; /* to assemble string constants */
    char *string_buf_ptr;

    extern int curr_lineno;
    extern int verbose_flag;

    extern YYSTYPE cool_yylval;

    // my definitions
    static int comments_depth, null_presented;
    static std::string current_string;

%}

DIGIT           [0-9]
INTEGER         {DIGIT}+
ESCAPE		    \\
NEWLINE         \n
NULL_CHAR       \0
ONE_CHAR	    [:+\-*/=)(}{~.,;<@]
TRUE            t(?i:rue)
FALSE           f(?i:alse)
LPAREN          \(
RPAREN          \)
STAR            \*
ALPHABET        [a-zA-Z0-9_]
TYPE_ID         [A-Z]{ALPHABET}*
OBJECT_ID       [a-z]{ALPHABET}*
QUOTE           \"
HYPHEN          -
WHITESPACE      [ \t\r\f\v]
DARROW          =>

%x COMMENTS INLINE_COMMENT STRING

%%

(?i:class)	return CLASS;
(?i:else)	return ELSE;
(?i:fi)		return FI;
(?i:if)		return IF;
(?i:in)		return IN;
(?i:inherits)	return INHERITS;
(?i:let)	return LET;
(?i:loop)	return LOOP;
(?i:pool)	return POOL;
(?i:then)	return THEN;
(?i:while)	return WHILE;
(?i:case)	return CASE;
(?i:esac)	return ESAC;
(?i:of)		return OF;
(?i:new)	return NEW;
(?i:isvoid)	return ISVOID;
(?i:not)	return NOT;
"<="		return LE;
"<-"		return ASSIGN;

{TRUE}	{
    cool_yylval.boolean = 1;
    return BOOL_CONST;
}

{FALSE} {
    cool_yylval.boolean = 0;
    return BOOL_CONST;
}

{WHITESPACE}	;

{HYPHEN}{HYPHEN} {
    BEGIN INLINE_COMMENT;
}

{DARROW} {
    return (DARROW);
}

{ONE_CHAR} {
    return int(yytext[0]);
}

{NEWLINE}	curr_lineno++;


{INTEGER} {
    cool_yylval.symbol = inttable.add_string(yytext);
    return INT_CONST;
}

{TYPE_ID} {
    cool_yylval.symbol = idtable.add_string(yytext);
    return TYPEID;
}

{OBJECT_ID} {
    cool_yylval.symbol = idtable.add_string(yytext);
    return OBJECTID;
}

{STAR}{RPAREN} {
    cool_yylval.error_msg = "Unmatched *)";
    return ERROR;
}

{LPAREN}{STAR} {
    comments_depth++;
    BEGIN COMMENTS;
}

{QUOTE}	{
    BEGIN STRING;
    current_string = "";
    null_presented = 0;
}

. {
    cool_yylval.error_msg = yytext;
    return ERROR;
}

<INLINE_COMMENT>{NEWLINE} {
    curr_lineno++;
    BEGIN INITIAL;
}

<INLINE_COMMENT><<EOF>> {
    BEGIN INITIAL;
}

<INLINE_COMMENT>.	;

<STRING>{QUOTE}	{
    BEGIN INITIAL;
    if (current_string.size() >= MAX_STR_CONST) {
        cool_yylval.error_msg = "String constant too long";
	    return ERROR;
    }
    if (null_presented) {
       cool_yylval.error_msg = "String contains null character";
       return ERROR;
    }
    cool_yylval.symbol = stringtable.add_string((char *)current_string.c_str());
    return STR_CONST;
}

<STRING>{ESCAPE}{NEWLINE} {
    current_string += '\n';
}

<STRING>{NEWLINE} {
    BEGIN INITIAL;
    curr_lineno++;
    cool_yylval.error_msg = "Unterminated string constant";
    return ERROR;
}

<STRING>{NULL_CHAR} {
    null_presented = 1;
}

<STRING>{ESCAPE}. {
    char ch;
    switch((ch = yytext[1])) {
        case 'v':
	    current_string += '\v';
	    break;
	case 't':
	    current_string += '\t';
	    break;
	case 'n':
	    current_string += '\n';
	    break;
	case 'f':
	    current_string += '\f';
	    break;
	case 'r':
	    current_string += '\r';
	    break;
	case '\0':
	    null_presented = 1;
	    break;
	default:
	    current_string += ch;
            break;
    }
}

<STRING><<EOF>> {
    BEGIN INITIAL;
    cool_yylval.error_msg = "EOF in string";
    return ERROR;
}

<STRING>. {
    current_string += yytext;
}

<COMMENTS>{LPAREN}{STAR} {
    comments_depth++;
}

<COMMENTS>{STAR}{RPAREN} {
    comments_depth--;
    if (comments_depth == 0) {
       BEGIN INITIAL;
    }
}

<COMMENTS>{NEWLINE} {
    curr_lineno++;
}

<COMMENTS><<EOF>> {
    BEGIN INITIAL;
    cool_yylval.error_msg = "EOF in comment";
    return ERROR;
}

<COMMENTS>.	;

%%
