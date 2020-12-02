package com.xrfintech.fims.ui.service;

import com.querydsl.core.types.dsl.BooleanExpression;
import com.querydsl.jpa.impl.JPAQuery;
import com.xrfintech.common.constants.DateTimePatternConstants;
import com.xrfintech.common.errorcode.SysError;
import com.xrfintech.common.exception.ProcessException;
import com.xrfintech.fims.repository.model.FimsOrder;
import com.xrfintech.fims.repository.model.QFimsOrder;
import com.xrfintech.fims.repository.repos.RFimsOrder;
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
 * FimsOrderService
 *
 * @Author: lifan
 * @CreateTime: 2020-10-29
 * @Description:
 */
@Service
public class FimsOrderService {
    private static final Logger logger = LoggerFactory.getLogger(FimsOrderService.class);

    @PersistenceContext
    private EntityManager em;

    @Autowired
    private RFimsOrder rFimsOrder;

        /**
        * 保存订单
        *
        */
        public PageResponse<?> fetchList(PageRequest request) {
        try {
            QFimsOrder qFimsOrder = QFimsOrder.fimsOrder;
            BooleanExpression exp = qFimsOrder.orderNo.isNotNull();
            if (request.getCriteriaMap() != null) {
                Map<String, String> criteriaMap = request.getCriteriaMap();
                String name = criteriaMap.get("name");
                if (StringUtils.isNotBlank(name)) {
                    exp = exp.and(qFimsOrder.name.eq("name"));
                }
                String loanBeginDateStartTime = criteriaMap.get("loanBeginDateStartTime");
                String loanBeginDateEndTime = criteriaMap.get("loanBeginDateEndTime");
                if (StringUtils.isNotBlank(loanBeginDateStartTime)) {
                exp = exp.and(qFimsOrder.loanBeginDate.goe(DateUtil.parseDate(loanBeginDateStartTime,
                DateTimePatternConstants.DATE_LINE)));
                }
                if (StringUtils.isNotBlank(loanBeginDateEndTime)) {
                exp = exp.and(qFimsOrder.loanBeginDate.lt(DateUtil.addDays(
                (DateUtil.parseDate(loanBeginDateEndTime, DateTimePatternConstants.DATE_LINE)), 1)));
                }
            }

            JPAQuery<QFimsOrder> query = new JPAQuery<>(em);
            query.select(qFimsOrder)
                    .from(qFimsOrder)
                    .where(exp);

            if (StringUtils.isBlank(request.getSortName())) {
                query.orderBy(qFimsOrder.createTime.desc());
            }

            PageResponse<?> pageResponse = (new JPAPaginationQueryBuilder(request, query))
                    .addFieldMapping(qFimsOrder)
                    .build();
            return pageResponse;
        } catch (Exception e) {
            logger.error("订单列表查询出错", e);
            throw new ProcessException("订单列表查询出错", e);
        }
    }
    /**
    * 保存订单
    *
    */
    @Transactional(rollbackFor = Exception.class)
    public void saveFimsOrder(FimsOrder lFimsOrder) {
        try{
            rFimsOrder.save(lFimsOrder);
        }catch(Exception e){
            logger.error("保存订单异常");
        }
    }
    /**
    * 查询订单
    *
    */
    public FimsOrder queryFimsOrder(String orderNo) {
        FimsOrder bFimsOrder = rFimsOrder.findOne(orderNo);
        return bFimsOrder;
    }
    /**
    * 删除订单
    *
    */
    @Transactional(rollbackFor = Exception.class)
    public void deleteFimsOrder(String orderNo) {
        rFimsOrder.delete(orderNo);
    }
     <#import>
    import d from sdfa
}
