grammar Calc;   //名称需要和文件名一致
@header {        //一种action,定义生成的词法语法解析文件的头，当使用java的时候，生成的类需要包名，可以在这里统一定义
 package com.xcn.calc;
 }
s : expr EOF;   //解决问题: no viable alternative at input '<EOF>'
expr
    : expr '+' expr     #add   //标签会生成对应访问方法方便我们实现调用逻辑编写
    | expr '-' expr     #sub
    | INT               #int
    ;
INT : [0-9]+                   //定义整数
    ;
WS
    : [ \r\n\t]+ -> skip      //跳过空白类字符
    ;
