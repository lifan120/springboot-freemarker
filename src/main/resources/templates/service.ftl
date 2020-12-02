package com.xrfintech.${module}.ui.service;

import com.querydsl.core.types.dsl.BooleanExpression;
import com.querydsl.jpa.impl.JPAQuery;
import com.xrfintech.common.constants.DateTimePatternConstants;
import com.xrfintech.common.errorcode.SysError;
import com.xrfintech.common.exception.ProcessException;
import com.xrfintech.${module}.repository.model.${tableName};
import com.xrfintech.${module}.repository.model.Q${tableName};
import com.xrfintech.${module}.repository.repos.R${tableName};

<#if joinSelectColumnInfos??&&(joinSelectColumnInfos?size>0)>
import com.xrfintech.${module}.repository.model.${joinTableName};
import com.xrfintech.${module}.repository.model.Q${joinTableName};
import com.xrfintech.${module}.repository.repos.R${joinTableName};
</#if>

import com.xrfintech.common.serializable.JsonSerializeUtil;
import com.xrfintech.common.utils.DateUtil;
import com.xrfintech.fims.ui.entity.SubEnterpriseInfo;
import com.xrfintech.orm.pagination.JPAPaginationQueryBuilder;
import com.xrfintech.sysmng.util.UserUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import com.xrfintech.message.support.api.PageRequest;
import com.xrfintech.message.support.api.PageResponse;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;


/**
 * ${tableName}Service
 *
 * @Author: lifan
 * @CreateTime: 2020-10-29
 * @Description:
 */
@Service
public class ${tableName}Service {
    private static final Logger logger = LoggerFactory.getLogger(${tableName}Service.class);

    @PersistenceContext
    private EntityManager em;

    @Autowired
    private R${tableName} r${tableName};

    <#if joinSelectColumnInfos??&&(joinSelectColumnInfos?size>0)>
    @Autowired
    private R${joinTableName} r${joinTableName};
    </#if>

        /**
        * 查询${tableCnName}
        *
        */
        public PageResponse<?> fetchList(PageRequest request) {
        try {
            Q${tableName} q${tableName} = Q${tableName}.${lcTableName};
            <#if joinSelectColumnInfos??&&(joinSelectColumnInfos?size>0)>
            Q${joinTableName} q${joinTableName} = Q${joinTableName}.${lcJoinTableName};
            </#if>

            BooleanExpression exp = q${tableName}.${primaryKey}.isNotNull();
            <#if joinSelectColumnInfos??&&(joinSelectColumnInfos?size>0)>
            exp = exp.and(q${tableName}.${primaryKey}.eq(q${joinTableName}.${joinColumnName}));
            </#if>
            if (request.getCriteriaMap() != null) {
                Map<String, String> criteriaMap = request.getCriteriaMap();
                <#list tableInfos as tableInfo>
                <#if tableInfo.dataType == 'date'>
                String ${tableInfo.columnName}StartTime = criteriaMap.get("${tableInfo.columnName}StartTime");
                String ${tableInfo.columnName}EndTime = criteriaMap.get("${tableInfo.columnName}EndTime");
                if (StringUtils.isNotBlank(${tableInfo.columnName}StartTime)) {
                exp = exp.and(q${tableName}.${tableInfo.columnName}.goe(DateUtil.parseDate(${tableInfo.columnName}StartTime,
                DateTimePatternConstants.DATE_LINE)));
                }
                if (StringUtils.isNotBlank(${tableInfo.columnName}EndTime)) {
                exp = exp.and(q${tableName}.${tableInfo.columnName}.lt(DateUtil.addDays(
                (DateUtil.parseDate(${tableInfo.columnName}EndTime, DateTimePatternConstants.DATE_LINE)), 1)));
                }
                <#else >
                 String ${tableInfo.columnName} = criteriaMap.get("${tableInfo.columnName}");
                 if (StringUtils.isNotBlank(${tableInfo.columnName})) {
                 exp = exp.and(q${tableName}.${tableInfo.columnName}.eq(${tableInfo.columnName}));
                 }
                </#if>
                </#list>

                <#if joinSelectColumnInfos??&&(joinSelectColumnInfos?size>0)>
                    <#list joinSelectColumnInfos as joinSelectColumnInfo>
                        <#if joinSelectColumnInfo.dataType == 'date'>
                            String ${joinSelectColumnInfo.columnName}StartTime = criteriaMap.get("${joinSelectColumnInfo.columnName}StartTime");
                            String ${joinSelectColumnInfo.columnName}EndTime = criteriaMap.get("${joinSelectColumnInfo.columnName}EndTime");
                            if (StringUtils.isNotBlank(${joinSelectColumnInfo.columnName}StartTime)) {
                            exp = exp.and(q${joinTableName}.${joinSelectColumnInfo.columnName}.goe(DateUtil.parseDate(${joinSelectColumnInfo.columnName}StartTime,
                            DateTimePatternConstants.DATE_LINE)));
                            }
                            if (StringUtils.isNotBlank(${joinSelectColumnInfo.columnName}EndTime)) {
                            exp = exp.and(q${joinTableName}.${joinSelectColumnInfo.columnName}.lt(DateUtil.addDays(
                            (DateUtil.parseDate(${joinSelectColumnInfo.columnName}EndTime, DateTimePatternConstants.DATE_LINE)), 1)));
                            }
                        <#else >
                            String ${joinSelectColumnInfo.columnName} = criteriaMap.get("${joinSelectColumnInfo.columnName}");
                            if (StringUtils.isNotBlank(${joinSelectColumnInfo.columnName})) {
                            exp = exp.and(q${joinTableName}.${joinSelectColumnInfo.columnName}.eq(${joinSelectColumnInfo.columnName}));
                            }

                        </#if>
                    </#list>
                </#if>
            }

            JPAQuery<Q${tableName}> query = new JPAQuery<>(em);
            query.select(q${tableName}<#if joinSelectColumnInfos??&&(joinSelectColumnInfos?size>0)>,q${joinTableName}</#if>)
                    .from(q${tableName}<#if joinSelectColumnInfos??&&(joinSelectColumnInfos?size>0)>,q${joinTableName}</#if>)
                    .where(exp);

            if (StringUtils.isBlank(request.getSortName())) {
                query.orderBy(q${tableName}.createTime.desc());
            }

            PageResponse<?> pageResponse = (new JPAPaginationQueryBuilder(request, query))
                    .addFieldMapping(q${tableName})
                    <#if joinViewColumnInfos??&&(joinViewColumnInfos?size>0)>
                    <#list joinViewColumnInfos as joinViewColumnInfo>
                    .addFieldMapping(${joinTableName}.P_${joinViewColumnInfo.ucColumnName},q${joinTableName}.${joinViewColumnInfo.columnName})
                    </#list>
                    </#if>
                    .build();
            return pageResponse;
        } catch (Exception e) {
            logger.error("${tableCnName}列表查询出错", e);
            throw new ProcessException("${tableCnName}列表查询出错", e);
        }
    }
    /**
    * 保存${tableCnName}
    *
    */
    @Transactional(rollbackFor = Exception.class)
    public void save${tableName}(${tableName} l${tableName}) {
        try{
            r${tableName}.save(l${tableName});
        }catch(Exception e){
            logger.error("保存${tableCnName}异常");
        }
    }
    /**
    * 查询${tableCnName}
    *
    */
    public ${tableName} query${tableName}(String ${primaryKey}) {
        ${tableName} b${tableName} = r${tableName}.findOne(${primaryKey});
        return b${tableName};
    }
    /**
    * 删除${tableCnName}
    *
    */
    @Transactional(rollbackFor = Exception.class)
    public void delete${tableName}(String ${primaryKey}) {
        r${tableName}.delete(${primaryKey});
    }
}
