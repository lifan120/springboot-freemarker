package com.xrfintech.fims.ui.controller;

import com.xrfintech.common.errorcode.SysError;
import com.xrfintech.fims.ui.service.DelayPayService;
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

/**
 * FimsOrderController
 *
 * @Author: lifan
 * @CreateTime: 2020-11-11
 * @Description:
 */
@RestController
@RequestMapping(value = {"/fims/FimsOrder"})
public class FimsOrderController {

    public static final Logger logger = LoggerFactory.getLogger(FimsOrderController.class);

    @Autowired
    private FimsOrderService service;

    @RequestMapping(value = {"fetchList"}, method = RequestMethod.POST)
    @ApiOperation(value = "查询订单列表", notes = "查询订单列表")
    @ApiImplicitParams({@ApiImplicitParam(name = "name", value = "姓名"),
                        @ApiImplicitParam(name = "loanBeginDate", value = "贷款开始日期")
                        })
    public ApiResponse<PageResponse> fetchList(PageRequest pageRequest) {
        try {
            PageResponse pageInfo = service.fetchList(pageRequest);
            return ApiResponseUtil.ok(pageInfo);
        } catch (Exception e) {
            logger.error("查询订单异常", e);
            return ApiResponseUtil.fail(SysError.E9999, e.getMessage());
        }
    }


    @RequestMapping(value = { "saveFimsOrder" }, method = RequestMethod.POST)
    @ApiOperation(value = "保存订单", notes = "保存订单")
    public ApiResponse<?> saveOrUpdate(@RequestBody @ApiParam(name = "FimsOrder", value = "传入json格式", required = true) FimsOrder lFimsOrder){
        service.saveFimsOrder(lFimsOrder);
        return ApiResponseUtil.ok(null);
    }

    @RequestMapping(value = { "queryFimsOrder" }, method = RequestMethod.GET)
    @ApiOperation(value = "查询订单", notes = "查询订单")
    public ApiResponse<?> queryEnterpriseLoan(@ApiParam(name = "orderNo", value = "主键", required = true) String orderNo){
        return ApiResponseUtil.ok(service.queryFimsOrder(orderNo));
    }

    @RequestMapping(value = { "deleteFimsOrder" }, method = RequestMethod.POST)
    @ApiOperation(value = "删除订单", notes = "删除订单")
    public ApiResponse<?> deleteEnterpriseLoan(@RequestBody @ApiParam(name = "orderNo", value = "主键", required = true) String orderNo){
        service.deleteFimsOrder(orderNo);
        return ApiResponseUtil.ok(null);
    }
}

