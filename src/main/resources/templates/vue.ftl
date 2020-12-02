<template>
    <div class="app-container">
        <luna-el-table
                :ajax="table.ajax"
                :border="false"
                :column-attributes="table.columnAttributes"
                :hasOperationColumn="false"
                :operation-buttons="table.operationButtons"
                :pageable="true"
                :pk-names="['${primaryKey}']"
                :postAjaxDataProcess="postAjaxDataProcess"
                :search-attributes="table.searchAttributes"
                :searchFormLabelWidth="searchFormLabelWidth"
                :server-params="table.searchObj"
                :toolbar-buttons="table.toolbarButtons"
                ref="table"
                row-key="${primaryKey}"
                table-title="${tableCnName}列表"
                :operation-fixed="table.operationFixed"
                :operationWidth="table.operationWidth"
        >
        </luna-el-table>
    </div>
</template>

<script>
    import LunaElTable from '@/components/LunaElTable'
    import LunaElDialog from '@/components/LunaElDialog'
    import {deleteRole} from "@/api/sysmng/sysrole";
    import {moduleBaseUrls} from "@/utils/request";
    import {getOrgDictMap} from "@/api/sysmng/sysorg";
    import {exportTransList} from "@/api/fims/trans"
    import {getLabelByTypeAndCode, getOptionsByType} from "@/utils/dictionary";
    <#if isHaveExport??&&isHaveExport=='Y'>
    import {export${tableName}List} from "@/api/${module}/${tableName}";
    </#if>
    <#if isNeedDelete??&&isNeedDelete =='Y'>
    import {delete${tableName}} from "@/api/${module}/${tableName}";
    </#if>

    export default {
        name: 'l${tableName}Res',
        components: {LunaElTable, LunaElDialog},
        data() {
            return {
                // targetRoleId: null,
                id: 0,
                searchFormLabelWidth: '120px',
                orgDictMap: {},
                table: {
                    // 默认查询参数，如需要写死一个参数，用此方式传入到table组件
                    searchObj: {},
                    ajax: { // 也可以直接写http地址
                        url: '${module}/l${tableName}/fetchList',
                        baseURL: moduleBaseUrls.${module}
                    },
                    searchAttributes: [
                        <#list selectColumnInfos as selectColumn>
                        <#if  selectColumn.dataType == "date">
                        {
                            code: '${selectColumn.columnName}Range',
                            label: '${selectColumn.columnComment}',
                            placeholder: '请选择',
                            type: 'daterange',
                            valFormat: 'yyyy-MM-dd',
                            required: true,
                            fieldWidth: "250px",
                            labelWidth: '110px',
                            changed: (_v) => {
                                if (_v) {
                                    this.table.searchObj.${selectColumn.columnName}StartTime = _v[0];
                                    this.table.searchObj.${selectColumn.columnName}EndTime = _v[1];
                                } else {
                                    delete this.table.searchObj.${selectColumn.columnName}StartTime;
                                    delete this.table.searchObj.${selectColumn.columnName}EndTime;
                                }
                            }
                        },
                        <#else>
                        {
                            code: '${selectColumn.columnName}',
                            label: '${selectColumn.columnComment}',
                            type: 'text',
                            minLength: 0,
                            MaxLength: 80,
                            required: true,
                            labelWidth: '80px'
                        },
                        </#if>
                        </#list>

                        <#if joinSelectColumnInfos??&&(joinSelectColumnInfos?size>0)>
                        <#list joinSelectColumnInfos as joinSelectColumnInfo>

                        <#if joinSelectColumnInfo.dataType == "date">
                        {
                            code: '${joinSelectColumnInfo.columnName}Range',
                            label: '${joinSelectColumnInfo.columnComment}',
                            placeholder: '请选择',
                            type: 'daterange',
                            valFormat: 'yyyy-MM-dd',
                            required: true,
                            fieldWidth: "250px",
                            labelWidth: '110px',
                            changed: (_v) => {
                                if (_v) {
                                    this.table.searchObj.${joinSelectColumnInfo.columnName}StartTime = _v[0];
                                    this.table.searchObj.${joinSelectColumnInfo.columnName}EndTime = _v[1];
                                } else {
                                    delete this.table.searchObj.${joinSelectColumnInfo.columnName}StartTime;
                                    delete this.table.searchObj.${joinSelectColumnInfo.columnName}EndTime;
                                }
                            }
                        },
                        <#else>
                        {
                            code: '${joinSelectColumnInfo.columnName}',
                            label: '${joinSelectColumnInfo.columnComment}',
                            type: 'text',
                            minLength: 0,
                            MaxLength: 80,
                            required: true,
                            labelWidth: '80px'
                        },
                        </#if>
                        </#list>
                        </#if>
                    ],
                    columnAttributes: [
                        <#list viewColumnInfos as viewColumnInfo>
                        <#if viewColumnInfo.dataType == "date">
                        {
                            label: '${viewColumnInfo.columnComment}', prop: '${viewColumnInfo.columnName}', minWidth: 140, showOverflowTooltip: true,
                            formatter: function (row, column, cellValue, index) {
                                return this.vDate.format(cellValue, 'date');
                            }
                        },
                        <#else>
                        {
                            label: '${viewColumnInfo.columnComment}', prop: '${viewColumnInfo.columnName}', minWidth: 150, showOverflowTooltip: true
                        },
                        </#if>
                        </#list>

                        <#if joinViewColumnInfos??&&(joinViewColumnInfos?size>0)>
                        <#list joinViewColumnInfos as joinViewColumnInfo>
                        <#if joinViewColumnInfo.dataType == "date">
                        {
                            label: '${joinViewColumnInfo.columnComment}', prop: '${joinViewColumnInfo.columnName}', minWidth: 140, showOverflowTooltip: true,
                            formatter: function (row, column, cellValue, index) {
                                return this.vDate.format(cellValue, 'date');
                            }
                        },
                        <#else >
                        {
                            label: '${joinViewColumnInfo.columnComment}', prop: '${joinViewColumnInfo.columnName}', minWidth: 150, showOverflowTooltip: true
                        },
                        </#if>

                        </#list>
                        </#if>
                    ],
                    toolbarButtons: [
                        <#if isHaveExport??&&isHaveExport=='Y'>
                        {
                            label: '导出', type: 'primary', icon: 'el-icon-plus', btnAuth: ['${module}:${tableName}List:export'],
                            btnClick: () => {

                                let searchObj = Object.assign({}, this.table.searchObj, this.$refs.table.searchForm)

                                const loading = this.$loading({
                                    lock: true,
                                    text: 'Loading',
                                    spinner: 'el-icon-loading',
                                    background: 'rgba(0, 0, 0, 0.7)'
                                });
                                export${tableName}List(searchObj).then(response => {
                                    const link = document.createElement('a')
                                    let blob = new Blob([response.data], {type: 'application/vnd.ms-excel'})
                                    link.style.display = 'none'
                                    link.href = URL.createObjectURL(blob)

                                    let contentDisposition = response.headers['content-disposition'] //下载后文件名
                                    if (contentDisposition) {
                                        link.download = window.decodeURI(contentDisposition.split('=')[1], "UTF-8");
                                    }
                                    document.body.appendChild(link)
                                    link.click()
                                    document.body.removeChild(link)
                                    loading.close(z);

                                }).catch((error) => {
                                    loading.close();
                                    console.error(error)
                                    this.$message.error(error);
                                })
                            }
                        },
                        </#if>
                    ],
                    toolbarItems: [],
                    operationWidth: 100,
                    operationButtons: [
                        <#if isNeedDelete??&&isNeedDelete =='Y'>
                        {
                            label: '删除', type: 'primary', icon: '', btnAuth: ['${module}:${tableName}:delete'],
                            btnClick: (row, column, index) => {
                                this.$confirm('确定要删除吗？', '提示', {
                                    confirmButtonText: '确定',
                                    cancelButtonText: '取消',
                                    type: 'warning'
                                }).then(() => {
                                    delete${tableName}(row.${primaryKey}).then(()=>{
                                        this.$refs.table.refreshTable();
                                        this.$message({
                                            type: 'success',
                                            message: '删除成功!'
                                        });
                                    })
                                })
                            }
                        }
                        </#if>
                    ]
                }
            }
        },
        created() {
        },
        methods: {
            refreshTable: function () {
                this.$refs.table.reLoadTable();
            },
            postAjaxDataProcess: function (data) {
                <#list selectColumnInfos as selectColumn>
                <#if selectColumn.dataType == "date">
                if (data.criteriaMap.${selectColumn.columnName}Range) {
                    data.criteriaMap.${selectColumn.columnName}Range = '';
                } else {
                    data.criteriaMap.${selectColumn.columnName}StartTime = null;
                    data.criteriaMap.${selectColumn.columnName}EndTime = null;
                    this.table.searchObj.${selectColumn.columnName}StartTime = null;
                    this.table.searchObj.${selectColumn.columnName}EndTime = null;
                }
                </#if>
                </#list>
            }
        }
    }
</script>

<style scoped>
    .warning-row {
        background-color: oldlace;
    }
</style>
