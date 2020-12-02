package com.lf.freemarker.bean;

import lombok.Data;

/**
 * TableInfo
 *
 * @Author: lifan
 * @CreateTime: 2020-11-28
 * @Description:
 */
@Data
public class TableInfo {
    /**
     *列名
     */
    private String columnName;
    /**
     *数据类型
     */
    private String dataType;
    /**
     * 列索引
     */
    private String columnKey;
    /**
     *列备注
     */
    private String columnComment;
}
