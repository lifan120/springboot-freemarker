<!DOCTYPE html>
<html>
<head>
    <title>FreeMarker Spring MVC 之 表单提交</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
<div>选择表</div>
<form name="frmLogin" action="/chooseColumn">
    <!-- 下拉框 -->
    <select name="tableName" size="1" >
        <#list tableNameList as tableName>
        <option value="${tableName}">${tableName}</option>
        </#list>
    </select>
    <div>

    </div>
    <input type="submit">
</form>

</body>
