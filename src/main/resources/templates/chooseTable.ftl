<!DOCTYPE html>
<html>
<head>
    <title>代码生成</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
<div>代码生成选择表</div>
<form name="frmLogin" action="/chooseColumn">
    <!-- 下拉框 -->
    <select name="tableName" size="1" >
        <#list tableNameList as tableName>
        <option value="${tableName}">${tableName}</option>
        </#list>
    </select>
    <br/>
    是否需要连表查询
    是<input type="radio" name="isJoinTable" value="Y"/>
    否<input type="radio" name="isJoinTable" value="N"/>
    <br/>
    请选择要连接的表
    <!-- 下拉框 -->
    <select name="joinTableName" size="1" >
        <#list tableNameList as tableName>
            <option value="${tableName}">${tableName}</option>
        </#list>
    </select>
    <div>

    </div>
    <input type="submit">
</form>

</body>
