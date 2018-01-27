//
//  TimetableDatasource.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-26.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

class TimetableDatasource: Datasource {
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [dayCell.self]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        return Int(columes)
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {//to Cell
        return nil//days[indexPath.item]
    }
    
}