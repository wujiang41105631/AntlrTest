grammar Hello;   //名称需要和文件名一致
@header {        //一种action,定义生成的词法语法解析文件的头，当使用java的时候，生成的类需要包名，可以在这里统一定义
 package com.xcn.hello;
 }
hello :
    'hello' ID
    |'Hello' ID;

luoji:
    LHS OP RHS;
ID:[a-zA-Z]+;
LHS :[a-zA-Z]+;
RHS : {-,+}?[0-9]+;
OP:{'>=','<=','>','<','==','!='};
WS : [ \t\r\n]+ -> skip ;    // 跳过空格、制表符、回车符和换行符
