package com.lf.freemarker.service;

import com.lf.freemarker.bean.TableInfo;
import com.lf.freemarker.dao.TableDao;
import freemarker.template.Configuration;
import freemarker.template.Template;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * GenerateService
 *
 * @Author: lifan
 * @CreateTime: 2020-12-01
 * @Description:
 */
@Service
public class GenerateService {

    private static final String TEMPLATE_PATH = "src/main/resources/templates";
    private static final String CLASS_PATH = "D:/src/generate/code";
    private static final String DATA_BASE_NAME = "dev_gmd_fimsdb";
    private static final String PRIMARY = "PRI";

    @Value("${classpath}")
    private String classPath;

    @Autowired
    private TableDao dao;

    public String generateController(String tableName, String tableCnName, List<String> selectColumns,String isHaveExport,List<String> exportColumns) {
        //开始生成代码逻辑
        //根据表名生成controller,随后生成service
        Configuration configuration = new Configuration(Configuration.VERSION_2_3_0);
        Writer out = null;
        try {
            // step2 获取模版路径
            configuration.setDirectoryForTemplateLoading(new File(TEMPLATE_PATH));
            // step3 创建数据模型
            Map<String, Object> dataMap = generateControllerDataMap(tableName, selectColumns,exportColumns);
            dataMap.put("tableCnName", tableCnName);
            dataMap.put("isHaveExport", isHaveExport);
            // step4 加载模版文件
            Template template = configuration.getTemplate("controller.ftl");
            // step5输出文件
            String controllerName = underline2Camel(tableName, true) + "Controller.java";
            String controllerPath = classPath + "\\" + controllerName;
            File docFile = new File(classPath + "\\" + controllerName);
            out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(docFile)));
            template.process(dataMap, out);
            System.out.println("^^^^^^^^^^^^^^^^^^^^^^^^" + controllerName + " 文件创建成功 !");
            return controllerPath;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (null != out) {
                    out.flush();
                    out.close();
                }
            } catch (Exception e2) {
                e2.printStackTrace();
            }
        }
        return null;
    }

    private Map<String, Object> generateControllerDataMap(String tableName, List<String> selectColumns,List<String> exportColumns) {
        Map<String, Object> dataMap = new HashMap<String, Object>();
        List<TableInfo> tableInfos = dao.selectAllTableInfo(DATA_BASE_NAME, tableName);

        List<TableInfo> exportTableInfos = dao.selectAllTableInfo(DATA_BASE_NAME, tableName);
        //查询表的主键
        tableInfos.stream().forEach(item -> {
            if (PRIMARY.equals(item.getColumnKey())) {
                dataMap.put("primaryKey", underline2Camel(item.getColumnName()));
            }
        });
        //先将module分解出来
        String module = tableName.substring(0, tableName.indexOf("_"));
        tableName = underline2Camel(tableName, true);
        dataMap.put("module", module);
        dataMap.put("tableName", tableName);
        //利用selectColumns将tableInfo筛选出来
        List<TableInfo> returnTableInfos = filterTableInfos(tableInfos, selectColumns);
        dataMap.put("tableInfos",returnTableInfos);

        List<TableInfo> exportColumnInfos = filterTableInfos(exportTableInfos, exportColumns);
        dataMap.put("exportColumnInfos", exportColumnInfos);
        return dataMap;
    }

    public void generateService(String tableName, List<String> selectColumns, String tableCnName) {
        Configuration configuration = new Configuration(Configuration.VERSION_2_3_0);
        Writer out = null;
        try {
            configuration.setDirectoryForTemplateLoading(new File(TEMPLATE_PATH));
            //渲染service模板
            Map<String, Object> dataMapToService = generateServiceDataMap(tableName, selectColumns, tableCnName);
            // step4 加载模版文件
            Template serviceTemplate = configuration.getTemplate("service.ftl");
            // step5输出文件
            String serviceName = underline2Camel(tableName, true) + "Service.java";
            File serviceDocFile = new File(classPath + "\\" + serviceName);
            out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(serviceDocFile)));
            serviceTemplate.process(dataMapToService, out);
            System.out.println("^^^^^^^^^^^^^^^^^^^^^^^^" + serviceName + " 文件创建成功 !");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (null != out) {
                    out.flush();
                    out.close();
                }
            } catch (Exception e2) {
                e2.printStackTrace();
            }
        }
    }

    private Map<String, Object> generateServiceDataMap(String tableName, List<String> selectColumns, String tableCnName) {
        Map<String, Object> mapDataToService = new HashMap<>();
        String module = tableName.substring(0, tableName.indexOf("_"));
        mapDataToService.put("module", module);
        mapDataToService.put("tableName", underline2Camel(tableName, true));
        mapDataToService.put("lcTableName", underline2Camel(tableName));
        mapDataToService.put("tableCnName", tableCnName);

        //将表的主键查询出来
        List<TableInfo> tableInfos = dao.selectAllTableInfo(DATA_BASE_NAME, tableName);
        tableInfos.stream().forEach(item -> {
            if (PRIMARY.equals(item.getColumnKey())) {
                mapDataToService.put("primaryKey", underline2Camel(item.getColumnName()));
            }
        });
        List<TableInfo> returnTableInfos = filterTableInfos(tableInfos, selectColumns);
        mapDataToService.put("tableInfos", returnTableInfos);
        return mapDataToService;
    }


    public void generateVue(String tableName,
                            String tableCnName,
                            List<String> selectColumns,
                            List<String> viewColumns,
                            String isHaveExport,
                            String isNeedDelete) {
        Configuration configuration = new Configuration(Configuration.VERSION_2_3_0);
        Writer out = null;
        try {
            configuration.setDirectoryForTemplateLoading(new File(TEMPLATE_PATH));
            //渲染service模板
            Map<String, Object> vueDataMap = generateVueDataMap(tableName, tableCnName, selectColumns, viewColumns);
            vueDataMap.put("isHaveExport",isHaveExport);
            vueDataMap.put("isNeedDelete",isNeedDelete);
            // step4 加载模版文件
            Template vueTemplate = configuration.getTemplate("vue.ftl");
            // step5输出文件
            String vueName = classPath + "\\" + "index.vue";
            File serviceDocFile = new File(classPath + "\\" + "index.vue");
            out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(serviceDocFile)));
            vueTemplate.process(vueDataMap, out);
            generateApi(vueDataMap,configuration);
            System.out.println("^^^^^^^^^^^^^^^^^^^^^^^^" + vueName + " 文件创建成功 !");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (null != out) {
                    out.flush();
                    out.close();
                }
            } catch (Exception e2) {
                e2.printStackTrace();
            }
        }
    }

    /**
     * 生成api
     * @param vueDataMap
     */
    private void generateApi(Map<String, Object> vueDataMap,Configuration configuration) {
        Writer out = null;
        try {
            //  加载模版文件
            Template vueTemplate = configuration.getTemplate("api.ftl");
            // 输出文件
            String vuePath = classPath + "\\" + vueDataMap.get("module")+".js";
            File serviceDocFile = new File(vuePath);
            out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(serviceDocFile)));
            vueTemplate.process(vueDataMap, out);
            System.out.println("^^^^^^^^^^^^^^^^^^^^^^^^" + vuePath + " 文件创建成功 !");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (null != out) {
                    out.flush();
                    out.close();
                }
            } catch (Exception e2) {
                e2.printStackTrace();
            }
        }

    }

    private Map<String, Object> generateVueDataMap(String tableName, String tableCnName, List<String> selectColumns, List<String> viewColumns) {
        Map<String, Object> vueDataMap = new HashMap<>();
        vueDataMap.put("tableName", underline2Camel(tableName,true));
        vueDataMap.put("tableCnName", tableCnName);
        String module = tableName.substring(0, tableName.indexOf("_"));
        vueDataMap.put("module", module);
        List<TableInfo> tableInfos = dao.selectAllTableInfo(DATA_BASE_NAME, tableName);
        List<TableInfo> selectColumnInfos = filterTableInfos(tableInfos, selectColumns);
        vueDataMap.put("selectColumnInfos",selectColumnInfos);
        List<TableInfo> tableInfos2 = dao.selectAllTableInfo(DATA_BASE_NAME, tableName);
        List<TableInfo> viewColumnInfos = filterTableInfos(tableInfos2, viewColumns);
        vueDataMap.put("viewColumnInfos",viewColumnInfos);
        tableInfos.stream().forEach(item -> {
            if (PRIMARY.equals(item.getColumnKey())) {
                vueDataMap.put("primaryKey", underline2Camel(item.getColumnName()));
            }
        });
        return vueDataMap;
    }

    /**
     * 将字段信息过滤出来
     * @param tableInfos
     * @param columns
     * @return
     */
    private List<TableInfo> filterTableInfos(List<TableInfo> tableInfos, List<String> columns) {
        Set set = new HashSet(columns);
        List<TableInfo> returnTableInfos = new ArrayList<>();
        Iterator<TableInfo> iterator = tableInfos.iterator();
        while (iterator.hasNext()) {
            TableInfo next = iterator.next();
            if (set.contains(next.getColumnName())) {
                next.setColumnName(underline2Camel(next.getColumnName()));
                returnTableInfos.add(next);
            }
        }
        return returnTableInfos;
    }



    /**
     * 下划线转换为驼峰
     *
     * @param line 下划线字符串
     * @param firstIsUpperCase 首字母是否转换为大写
     * @return
     */
    private static String underline2Camel(String line, boolean ... firstIsUpperCase) {
        String str = "";

        if(StringUtils.isEmpty(line)){
            return str;
        } else {
            StringBuilder sb = new StringBuilder();
            String [] strArr;
            // 不包含下划线，且第二个参数是空的
            if(!line.contains("_") && firstIsUpperCase.length == 0){
                sb.append(line.substring(0, 1).toLowerCase()).append(line.substring(1));
                str = sb.toString();
            } else if (!line.contains("_") && firstIsUpperCase.length != 0){
                if (!firstIsUpperCase[0]) {
                    sb.append(line.substring(0, 1).toLowerCase()).append(line.substring(1));
                    str = sb.toString();
                } else {
                    sb.append(line.substring(0, 1).toUpperCase()).append(line.substring(1));
                    str = sb.toString();
                }
            } else if (line.contains("_") && firstIsUpperCase.length == 0) {
                strArr = line.split("_");
                for (String s : strArr) {
                    sb.append(s.substring(0, 1).toUpperCase()).append(s.substring(1));
                }
                str = sb.toString();
                str = str.substring(0, 1).toLowerCase() + str.substring(1);
            } else if (line.contains("_") && firstIsUpperCase.length != 0) {
                strArr = line.split("_");
                for (String s : strArr) {
                    sb.append(s.substring(0, 1).toUpperCase()).append(s.substring(1));
                }
                if (!firstIsUpperCase[0]) {
                    str = sb.toString();
                    str = str.substring(0, 1).toLowerCase() + str.substring(1);
                } else {
                    str = sb.toString();
                }
            }
        }
        return str;
    }

}
