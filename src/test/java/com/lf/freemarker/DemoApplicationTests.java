package com.lf.freemarker;

import com.lf.freemarker.bean.TableInfo;
import com.lf.freemarker.dao.TableDao;
import freemarker.template.Configuration;
import freemarker.template.Template;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@SpringBootTest
class DemoApplicationTests {
    private static final String TEMPLATE_PATH = "src/main/resources/templates";
    private static final String CLASS_PATH = "src/main/java/com/lf/freemarker/controller";
    @Autowired
    private TableDao dao;
    @Test
    void contextLoads() {
        Configuration configuration = new Configuration();
        Writer out = null;
        try {
            // step2 获取模版路径
            configuration.setDirectoryForTemplateLoading(new File(TEMPLATE_PATH));
            // step3 创建数据模型
            Map<String, Object> dataMap = new HashMap<String, Object>();
            List<TableInfo> tableInfos = dao.selectAllTableInfo("db2019", "payment");
            dataMap.put("tableInfos",tableInfos);
            // step4 加载模版文件
            Template template = configuration.getTemplate("controller.ftl");
            // step5 生成数据
            File docFile = new File(CLASS_PATH + "\\" + "User.java");
            out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(docFile)));
            // step6 输出文件
            template.process(dataMap, out);
            System.out.println("^^^^^^^^^^^^^^^^^^^^^^^^User.java 文件创建成功 !");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (null != out) {
                    out.flush();
                }
            } catch (Exception e2) {
                e2.printStackTrace();
            }
        }
    }


}
