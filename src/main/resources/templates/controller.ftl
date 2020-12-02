package com.xrfintech.${module}.ui.controller;

import com.xrfintech.common.errorcode.SysError;
import com.xrfintech.${module}.ui.service.${tableName}Service;
import com.xrfintech.message.support.api.ApiResponse;
import com.xrfintech.message.support.api.PageRequest;
import com.xrfintech.message.support.api.PageResponse;
import com.xrfintech.message.support.utils.ApiResponseUtil;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * ${tableName}Controller
 *
 * @Author: lifan
 * @CreateTime: 2020-11-11
 * @Description:
 */
@RestController
@RequestMapping(value = {"/${module}/l${tableName}"})
public class ${tableName}Controller {

    public static final Logger logger = LoggerFactory.getLogger(${tableName}Controller.class);
    <#if isHaveExport??&&isHaveExport=='Y'>
    private static final String[] EXPORT_TITLES = { <#list exportColumnInfos as columnInfo>"${columnInfo.columnComment}"<#if columnInfo_has_next || joinExportColumnInfos??>,</#if></#list>
<#if joinSelectColumnInfos??&&(joinSelectColumnInfos?size>0)><#list joinExportColumnInfos as joinExportColumnInfo>"${joinExportColumnInfo.columnComment}"<#if joinExportColumnInfo_has_next>,</#if></#list></#if>};
    private static final String EXPORT_EXC_NAME = "${tableCnName}列表";
    </#if>
    @Autowired
    private ${tableName}Service service;

    @Autowired
    private JXLExcelUtils jxlExcelUtils;

    @RequestMapping(value = {"fetchList"}, method = RequestMethod.POST)
    @ApiOperation(value = "查询${tableCnName}列表", notes = "查询${tableCnName}列表")
    @ApiImplicitParams({<#list tableInfos as tableInfo>@ApiImplicitParam(name = "${tableInfo.columnName}", value = "${tableInfo.columnComment}")<#if tableInfo_has_next || joinSelectColumnInfos??>,</#if>
                        </#list>
                        <#if joinSelectColumnInfos??&&(joinSelectColumnInfos?size>0)>
                        <#list joinSelectColumnInfos as joinSelectColumnInfo>
                                                       @ApiImplicitParam(name = "${joinSelectColumnInfo.columnName}", value = "${joinSelectColumnInfo.columnComment}")<#if joinSelectColumnInfo_has_next>,</#if>
                        </#list>}</#if>)
    public ApiResponse<PageResponse> fetchList(PageRequest pageRequest) {
        try {
            PageResponse pageInfo = service.fetchList(pageRequest);
            return ApiResponseUtil.ok(pageInfo);
        } catch (Exception e) {
            logger.error("查询${tableCnName}异常", e);
            return ApiResponseUtil.fail(SysError.E9999, e.getMessage());
        }
    }


    @RequestMapping(value = { "save${tableName}" }, method = RequestMethod.POST)
    @ApiOperation(value = "保存${tableCnName}", notes = "保存${tableCnName}")
    public ApiResponse<?> saveOrUpdate(@RequestBody @ApiParam(name = "${tableName}", value = "传入json格式", required = true) ${tableName} l${tableName}){
        service.save${tableName}(l${tableName});
        return ApiResponseUtil.ok(null);
    }

    @RequestMapping(value = { "query${tableName}" }, method = RequestMethod.GET)
    @ApiOperation(value = "查询${tableCnName}", notes = "查询${tableCnName}")
    public ApiResponse<?> queryEnterpriseLoan(@ApiParam(name = "${primaryKey}", value = "主键", required = true) String ${primaryKey}){
        return ApiResponseUtil.ok(service.query${tableName}(${primaryKey}));
    }

    @RequestMapping(value = { "delete${tableName}" }, method = RequestMethod.POST)
    @ApiOperation(value = "删除${tableCnName}", notes = "删除${tableCnName}")
    public ApiResponse<?> deleteEnterpriseLoan(@RequestBody @ApiParam(name = "${primaryKey}", value = "主键", required = true) String orderNo){
        service.delete${tableName}(${primaryKey});
        return ApiResponseUtil.ok(null);
    }

    @RequestMapping(value = "export${tableName}List", method = RequestMethod.GET)
    @ApiOperation(value = "导出excel文件", notes = "导出excel文件")
    @ApiImplicitParams({<#list tableInfos as tableInfo>@ApiImplicitParam(name = "${tableInfo.columnName}", value = "${tableInfo.columnComment}")<#if tableInfo_has_next>,</#if>
    </#list>})
    public ApiResponse<?> export${tableName}List(@RequestParam Map<String, String> paramMap, HttpServletResponse response) {
         try{
             PageRequest pageReq = new PageRequest();
             pageReq.setCriteriaMap(paramMap);
             //根据查询条件查询出需要导出的订单对象列表
             PageResponse<?> reps = service.fetchList(pageReq);
             List<Map<String, Object>> rowList = (List<Map<String, Object>>) reps.getRowList();

             List<List<Object>> dataList = new ArrayList<List<Object>>();
             if(rowList!=null){
               for (int i = 0; i < rowList.size(); i++) {
               //每一行数据(对象)
                 Map<String, Object> map = rowList.get(i);
                 List<Object> list = new ArrayList<Object>();
                 <#if exportColumnInfos??&&(exportColumnInfos?size>0)>
                 <#list exportColumnInfos as columnInfo>
                 list.add(map.get("${columnInfo.columnName}"));
                 </#list>
                 </#if>
                 <#if joinSelectColumnInfos??&&(joinSelectColumnInfos?size>0)>
                 <#list joinExportColumnInfos as joinExportColumnInfo>
                 list.add(map.get("${joinExportColumnInfo.columnName}"));
                 </#list>
                 </#if>
                 dataList.add(list);
               }
             }
             exportFile(EXPORT_EXC_NAME, EXPORT_TITLES, dataList, response,
             jxlExcelUtils);
         }catch (Exception e){
             logger.error("导出汇总报表", e);
             return ApiResponseUtil.fail(SysError.E9999, e.getMessage());
        }
       return ApiResponseUtil.ok(null);
   }

        /**
        * 导出Excel报表
        *
        */

        public void exportFile(String fileName, String[] titles, List<List<Object>> dataList, HttpServletResponse response, JXLExcelUtils jXLExcelUtils)
            throws ServletException, IOException {
            try {
            response.setContentType("application/msexcel;charset=UTF-8");
            response.setHeader("Content-Disposition",
            "attachment;filename=" + java.net.URLEncoder.encode(fileName + ".xls", "UTF-8"));

            ServletOutputStream out = response.getOutputStream();

            jXLExcelUtils.writeExcel(out, dataList, fileName, titles);

            out.flush();
            out.close();
            } catch (IllegalArgumentException e) {
            logger.error("Excel导出异常", e);
            response.getWriter().write(java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            } catch (FileNotFoundException e) {
            logger.error("Excel导出异常", e);
            response.getWriter().write(java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            }
       }



}

