import request from '@/utils/request'
import {moduleBaseUrls} from "../../utils/request";
import Qs from "qs";


/**：新增${tableCnName}
* **/
export function save${tableName}(data) {
return request({
headers:{
'Content-Type': 'application/json'
},
url: '${module}/l${tableName}/save${tableName}',
method: 'post',
data,
baseURL: moduleBaseUrls.${module}
})
}

/**：查询${tableCnName}
* **/
export function query${tableName}(data) {
return request({
url: '${module}/l${tableName}/query${tableName}',
method: 'get',
params: data,
baseURL: moduleBaseUrls.${module}
})
}
<#if isNeedDelete??&&isNeedDelete=='Y'>
/**
* 删除${tableCnName}
*/
export function delete${tableName}(data) {
return request({
headers:{
'Content-Type': 'application/json'
},
url: '${module}/l${tableName}/delete${tableName}',
method: 'post',
data: JSON.stringify(data),
baseURL: moduleBaseUrls.${module}
})
}
</#if>
<#if isHaveExport??&&isHaveExport=='Y'>
/**
* 导出${tableCnName}**/
export function exportRpt(data) {
return request({
url: '/${module}/l${tableName}/exportRpt',
method: 'get',
params: data,
paramsSerializer: function(params) {
return Qs.stringify(params, {arrayFormat: 'brackets'})
},
baseURL: moduleBaseUrls.${module},
responseType: 'blob'
})
}
</#if>
