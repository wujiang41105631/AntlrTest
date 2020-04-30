/**
https://www.cntofu.com/book/115/getting-started.md 一个简单的文档
1. grammar 语法,模块名
2. @header 文件生成包名
3. 规则: 每个规则对应 模块名Parser中的一个静态内部类 {XXXX}Context,在Context中记录了与其他Context的包含关系，还提供了获取parser中的lexer的方法，以及进出这个rule的回调函数
4. 代码动态生成:
    1> 右键g4文件, 点击configure ANTLR... 填写Language [java] 和 output directory[指定文件生成路径]
       package/nameSpace for the generate code 会重新生成package，如果@header添加了package，会生成两个package，报错
    2> 右键点击 Generate antlr Recognizer 动态生成代码
5. 代码解读
    1> DslLexer 词法解析类
    2> DslParser 语法解析类，在类中有各种Context,每个parser都赌对应了一个xxxContext的内部类，在Context中记录了与其他Context的包含关系，还提供了获取parser中的lexer的方法，以及进出这个rule的回调函数
    3> DslListener 语法解析监听器。antlr有listener和visitor两种遍历方式，前面配置的时候选择的是listener，因此只生成了listener。 在Listener中提供了进入和退出每一种规则的回调方法。我们可以通过实现Listtener类，按需覆写回调方法，以此来实现我们的业务。

   著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
**/

grammar Dsl;    //定义规则文件  grammar
@header {        //一种action,定义生成的词法语法解析文件的头，当使用java的时候，生成的类需要包名，可以在这里统一定义
 package com.xcn.antlr4;
 }

//parsers
sta:(sql ender)*;  //定义sta规则，里面包含了*（0个以上）个 sql ender组合规则
ender:';';  //定义ender规则，是一个分号
sql   //定义sql规则，sql规则有两条分支：select/load
    : SELECT ~(';')* as tableName   //select语法规则，以lexer SELECT开头， 以as tableName 结尾，其中as 和tableName分别是两个parser
    | LOAD format '.' path  as tableName //load语法规则,大致就是 load json.'path' as table1，load语法里面含有format，path， as，tableName四种规则
    ;    //sql规则结束符
as: AS;   //定义as规则，其内容指向AS这个lexer
tableName: identifier;  //tableName 规则，指向identifier规则
format: identifier;   //format规则，也指向identifier规则
path: quotedIdentifier; //path,指向quotedIdentifier 
identifier: IDENTIFIER | quotedIdentifier;  //identifier，指向lexer IDENTIFIER  或者parser quotedIdentifier
quotedIdentifier: BACKQUOTED_IDENTIFIER;  //quotedIdentifier,指向lexer BACKQUOTED_IDENTIFIER

//lexers antlr将某个句子进行分词的时候，分词单元就是如下的lexer
//keywords  定义一些关键字的lexer，忽略大小写
AS: [Aa][Ss];
LOAD: [Ll][Oo][Aa][Dd];
SELECT: [Ss][Ee][Ll][Ee][Cc][Tt];

//base  定义一些基础的lexer,
fragment DIGIT:[0-9];   //匹配数字
fragment LETTER:[a-zA-Z];  //匹配字母
STRING        //匹配带引号的文本
    : '\'' ( ~('\''|'\\') | ('\\' .) )* '\''
    | '"' ( ~('"'|'\\') | ('\\' .) )* '"'
    ;
IDENTIFIER    //匹配只含有数字字母和下划线的文本
    : (LETTER | DIGIT | '_')+
    ;
BACKQUOTED_IDENTIFIER   //匹配被``包裹的文本
    : '`' ( ~'`' | '``' )* '`'
    ;

//--hiden  定义需要隐藏的文本，指向channel(HIDDEN)就会隐藏。这里的channel可以自定义，到时在后台获取不同的channel的数据进行不同的处理
SIMPLE_COMMENT: '--' ~[\r\n]* '\r'? '\n'? -> channel(HIDDEN);   //忽略行注释
BRACKETED_EMPTY_COMMENT: '/**/' -> channel(HIDDEN);  //忽略多行注释
BRACKETED_COMMENT : '/*' ~[+] .*? '*/' -> channel(HIDDEN) ;  //忽略多行注释
WS: [ \r\n\t]+ -> channel(HIDDEN);  //忽略空白符

// 匹配其他的不能使用上面的lexer进行分词的文本
UNRECOGNIZED: .;