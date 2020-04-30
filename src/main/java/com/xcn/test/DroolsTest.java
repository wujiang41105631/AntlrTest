package com.xcn.test;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.sun.deploy.util.StringUtils;
import com.sun.xml.internal.ws.api.model.wsdl.WSDLOutput;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class DroolsTest {


    private static String templete = "package {packageName}\n" +
            "import java.util.Map\n" +
            "global java.util.Map resultMap\n" +
            "rule \"{ruleName}\"\n" +
            "   salience 100\n" +
            "   lock-on-active true\n" +
            "when\n" +
            "\teval({condition})\n" +
            "then\n" +
            "\t {action} \n" +
            "end\n" +
            "\n";

    public static void main(String[] args) throws IOException {
        String datas = FileUtils.readFileToString(new File("/Users/xupeng.guo/gitclone/AntlrTest/test.json"));
        JSONObject jsonObject = JSONObject.parseObject(datas);
        String packageName = jsonObject.getString("table");
        JSONArray rules = jsonObject.getJSONArray("rules");
        List<Map<String,String>> paramsList = new ArrayList<>();
        for(int i = 0;i<rules.size();i++){
            JSONObject jo = rules.getJSONObject(i);
            JSONArray jsonArray = jo.getJSONArray("execs");
            for(int k = 0;k<jsonArray.size();k++){
                Map<String,String> params = new HashMap<String, String>();
                params.put("packageName",packageName );
                params.put("ruleName",packageName + "_" + jo.getString("name" + "_" + k));
                params.put("condition",jsonArray.getJSONObject(k).getString("contition"));
                String actions = jsonArray.getJSONObject(k).getString("action") ;
                String[] actionsArray = actions.replaceAll(" ","").split(",");
                StringBuilder sb = new StringBuilder();
                if(jo.getString("type").equals("meta")){
                    for(String actionMeta : actionsArray){
                        String key = actionMeta.split("=")[0];
                        String v = actionMeta.split("=")[1];
                        sb.append("resultMap.put(\""+key+ "\","+v+");\n");
                    }
                    params.put("action",sb.toString());
                }else{
                    // todo 规则action 是聚合的话需要走一些聚合函数,暂时continue
                    continue;
                }
                System.out.println(buildString(templete,params));
                System.out.println("--------------");
            }
        }


    }


    public static String buildString(String ruleModel,Map<String,String> params){
        String reg = "\\{(.*?)\\}";
        Pattern pattern = Pattern.compile(reg);
        Matcher matcher = pattern.matcher(ruleModel);
        StringBuffer ruleBuffer = new StringBuffer();
        while (matcher.find()) {
            String jsonStr = matcher.group(1);
            String tempValue = params.get(jsonStr);
            matcher.appendReplacement(ruleBuffer, tempValue);
        }
        matcher.appendTail(ruleBuffer);
        return ruleBuffer.toString();
    }
}
