package com.lf.freemarker.dao;

import com.lf.freemarker.bean.TableInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * TableDao
 *
 * @Author: lifan
 * @CreateTime: 2020-11-28
 * @Description:
 */
@Mapper
public interface TableDao {
    /**
     * 获取所有的表信息根据数据库名
     * @param databaseName
     * @return
     */
    List<String> selectAllTableName(@Param("databaseName") String databaseName);

    /**
     * 获取所有表的列信息根据表名与数据库名
     * @param databaseName
     * @param tableName
     * @return
     */
    List<TableInfo> selectAllTableInfo(@Param("databaseName") String databaseName, @Param("tableName") String tableName);
}
