package com.lf.freemarker.controller;

import cn.hutool.core.util.ZipUtil;
import com.lf.freemarker.bean.TableInfo;
import com.lf.freemarker.dao.TableDao;
import com.lf.freemarker.service.GenerateService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

@Controller
public class GenerateController {
    private static final String DATA_BASE_NAME = "dev_gmd_fimsdb";

    @Value("${classpath}")
    private String classPath;
    @Autowired
    private TableDao dao;

    @Autowired
    private GenerateService service;

    @GetMapping("/chooseTable")
    public String chooseTable(Model model) {
        List<String> db2019 = dao.selectAllTableName(DATA_BASE_NAME);
        model.addAttribute("tableNameList",db2019);
        return "chooseTable";
    }

    @GetMapping("/chooseColumn")
    public String chooseColumn(@RequestParam("tableName") String tableName,
                               Model model,
                               @RequestParam("joinTableName") String joinTableName) {
        List<TableInfo> tableInfos = dao.selectAllTableInfo(DATA_BASE_NAME, tableName);
        List<TableInfo> joinTableInfos = dao.selectAllTableInfo(DATA_BASE_NAME,joinTableName);
        model.addAttribute("tableInfos",tableInfos);
        model.addAttribute("joinTableInfos",joinTableInfos);
        model.addAttribute("tableName",tableName);
        model.addAttribute("joinTableName",joinTableName);
        return "selectColumn";
    }
    @ResponseBody
    @GetMapping("/generateCode")
    public ResponseEntity<byte[]> generateCode(@RequestParam("tableName") String tableName,
                                               @RequestParam("tableCnName") String tableCnName,
                                               @RequestParam("selectColumn") List<String> selectColumns,
                                               @RequestParam("viewColumn") List<String> viewColumns,
                                               @RequestParam(value = "joinTableName",required = false) String joinTableName,
                                               @RequestParam(value = "joinColumnName",required = false) String joinColumnName,
                                               @RequestParam(value = "joinSelectColumn",required = false) List<String> joinSelectColumn,
                                               @RequestParam(value = "joinViewColumn",required = false) List<String> joinViewColumn,
                                               @RequestParam("isHaveExport") String isHaveExport,
                                               @RequestParam(value = "joinExportColumn",required = false) List<String> joinExportColumn,
                                               @RequestParam(value = "exportColumn",required = false) List<String> exportColumns,
                                               @RequestParam("isNeedDelete") String isNeedDelete){
        service.generateController(tableName, tableCnName, selectColumns,isHaveExport,exportColumns,joinTableName,joinSelectColumn,joinExportColumn);
        service.generateService(tableName,selectColumns,tableCnName,joinTableName,joinColumnName,joinSelectColumn,joinViewColumn);
        service.generateVue(tableName,tableCnName,selectColumns,viewColumns,isHaveExport,isNeedDelete,joinTableName,joinSelectColumn,joinViewColumn);

        //压缩生成后文件所在的文件夹
        File zip = ZipUtil.zip(classPath);

        File file;
        InputStream is = null;
        try {
            file = new File(zip.getPath());
            byte[] body = null;
            is = new FileInputStream(file);
            body = new byte[is.available()];
            is.read(body);
            HttpHeaders headers = new HttpHeaders();
            headers.add("Content-Disposition", "attchement;filename=" + file.getName());
            HttpStatus statusCode = HttpStatus.OK;
            ResponseEntity<byte[]> entity = new ResponseEntity<byte[]>(body, headers, statusCode);
            return entity;
        }catch (Exception e){
            throw new RuntimeException(e);
        }finally {
            if(is != null){
                try {
                    is.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }


}
