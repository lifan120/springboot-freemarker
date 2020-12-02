package com.lf.freemarker.bean;

import lombok.Data;

import java.io.Serializable;

/**
 * TableInfo
 *
 * @Author: lifan
 * @CreateTime: 2020-11-28
 * @Description:
 */
@Data
public class TableInfo implements Serializable {
    /**
     *列名
     */
    private String columnName;

    /**
     * 大写列名
     */
    private String ucColumnName;
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
