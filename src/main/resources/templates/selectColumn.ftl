<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <title>代码生成选择列</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
<div>选择查询列</div>
<form name="frmLogin" action="/generateCode">
    <!-- 下拉框 -->
    选择的表
    <br/>
    中文名:<input  name="tableCnName"/>
    英文名:<input readonly="readonly" name="tableName" value="${tableName}"/>
    <br/>
    关联的表
    <br/>
    英文名:<input readonly="readonly" name="joinTableName" value="${joinTableName}"/>
    <br/>
    请选择关联的条件字段
    <#list joinTableInfos as joinTableInfo>
        <#if joinTableInfo_index%5==0>
            <br>
        </#if>
        <input type="radio" name="joinColumnName" value="${joinTableInfo.columnName}"  >
            ${joinTableInfo.columnComment}
        </input>
    </#list>
    <br/>
    请选择需要查询的字段：
    <#list tableInfos as tableInfo>
        <#if tableInfo_index%5==0>
            <br>
        </#if>
        <input type="checkbox" name="selectColumn" value="${tableInfo.columnName}"  >
            ${tableInfo.columnComment}
        </input>
    </#list>
    <br/>
    关联表需要查询的字段：
    <br/>
    <#list joinTableInfos as joinTableInfo>
        <#if joinTableInfo_index%5==0>
            <br>
        </#if>
        <input type="checkbox" name="joinSelectColumn" value="${joinTableInfo.columnName}"  >
            ${joinTableInfo.columnComment}
        </input>
    </#list>
    <br/>
    请选择需要展示的字段：
    <#list tableInfos as tableInfo>
        <#if tableInfo_index%5==0>
            <br>
        </#if>
        <input type="checkbox" name="viewColumn" value="${tableInfo.columnName}"  >
            ${tableInfo.columnComment}
        </input>
    </#list>
    <br/>
    关联表需要展示的字段
    <#list joinTableInfos as joinTableInfo>
        <#if joinTableInfo_index%5==0>
            <br>
        </#if>
        <input type="checkbox" name="joinViewColumn" value="${joinTableInfo.columnName}"  >
            ${joinTableInfo.columnComment}
        </input>
    </#list>
    <br/>
    页面是否存在导出功能
    是<input type="radio" name="isHaveExport" value="Y"/>
    否<input type="radio" name="isHaveExport" value="N"/>

    <br/>
    请选择需要导出的字段（如不存在导出，则不用选择）
    <#list tableInfos as tableInfo>
        <#if tableInfo_index%5==0>
            <br>
        </#if>
        <input type="checkbox" name="exportColumn" value="${tableInfo.columnName}"  >
            ${tableInfo.columnComment}
        </input>
    </#list>
    <br/>
    关联表需要导出的字段：
    <br/>
    <#list joinTableInfos as joinTableInfo>
        <#if joinTableInfo_index%5==0>
            <br>
        </#if>
        <input type="checkbox" name="joinExportColumn" value="${joinTableInfo.columnName}"  >
            ${joinTableInfo.columnComment}
        </input>
    </#list>


    <br/>
    页面是否存在删除功能
    是<input type="radio" name="isNeedDelete" value="Y"/>
    否<input type="radio" name="isNeedDelete" value="N"/>
    <div>

    </div>
    <input type="submit">
</form>

</body>
