public with sharing class QueryBuilder {
  String[] fields;
  String obj;
  Integer qlimit;
  String[] orderBy;
  FilterBuilder rootFilter;

  String crossFilterObj;
  String crossFilterId;
  String crossFilterIdToQuery;

  Map<QBop, String> qbop2operator = new Map<QBop, String>{
    QBOp.QLIKE => 'LIKE',
    QBOp.QGT => '>',
    QBOp.QLT => '<',
    QBOp.QEQUAL => '=',
    QBOp.QNOT_EQUAL => '!=',
    QBOp.QIN => 'IN',
    QBOp.QNOT_IN => 'NOT IN',
    QBOp.QGTE => '>=',
    QBOp.QLTE => '<='
  };

  public class FilterBuilder {
    String[] filters;
    QueryBuilder qb;
    String operation;
    FilterBuilder parent;

    public FilterBuilder(QueryBuilder qb, String operation, FilterBuilder parent) {
      this.filters = new String[]{};
      this.qb = qb;
      this.operation = operation;
      this.parent = parent;
    }

    public FilterBuilder add(String field, QBOp op, Object value) {
      return add(field, op, value, null);
    }

    public FilterBuilder add(String field, QBOp op, Object value, Boolean rendered) {
      String v = getValue(value);
      QBOp o = op;
      if(v == '(\'\')') v = null;

      if((rendered == null && (v == null || v == '\'\'')) || (rendered != null && !rendered)) return this;
      else if(v == null || v == '\'\'') {
        if(v == null) v = 'NULL';
        if(op == QBOp.QIN || op == QBOp.QLIKE) o = QBOp.QEQUAL;
        else if(op == QBOp.QNOT_IN || op == QBOp.QNOT_LIKE) o = QBOp.QNOT_EQUAL;
      }

      if(o == QBOp.QLIKE || o == QBOp.QNOT_LIKE) v = v.replace('*', '%');

      filters.add(field + ' ' + getOperator(o) + ' ' + v);
      return this;
    }

    public FilterBuilder addUntyped(String filter) {
      return addUntyped(filter, true);
    }

    public FilterBuilder addUntyped(String filter, Boolean rendered) {
      if(rendered) filters.add(filter);
      return this;
    }

    public FilterBuilder end() {
      return end(true);
    }

    public FilterBuilder end(Boolean rendered) {
      if(parent != null && !filters.isEmpty()) {
        if(rendered) parent.addUntyped('(' + String.join(filters, operation == 'and' ? ' AND ' : ' OR ') + ')');
        filters = null;
      }
      return parent;
    }

    public QueryBuilder endFilter() {
      FilterBuilder current = this;
      while(current != null) {
        current = current.end();
      }
      return qb;
    }

    public FilterBuilder beginOr() {
      return new FilterBuilder(qb, 'or', this);
    }

    public FilterBuilder beginAnd() {
      return new FilterBuilder(qb, 'and', this);
    }

    public FilterBuilder beginCrossFilter(String obj, String idToMatch) {
      return beginCrossFilter(obj, 'Id', idToMatch);
    }

    public FilterBuilder beginCrossFilter(String obj, String idToQuery, String idToMatch) {
      qb.crossFilterObj = obj;
      qb.crossFilterIdToQuery = idToQuery;
      qb.crossFilterId = idToMatch;
      return new FilterBuilder(qb, 'and', this);
    }

    public FilterBuilder endCrossFilter() {
      return endCrossFilter(true);
    }

    public FilterBuilder endCrossFilter(Boolean renderedIfNoFilters) {
      return endCrossFilter(renderedIfNoFilters, true);
    }

    public FilterBuilder endCrossFilter(Boolean renderedIfNoFilters, Boolean rendered) {
      return endCrossFilter(renderedIfNoFilters, rendered, true);
    }

    public FilterBuilder endCrossFilter(Boolean renderedIfNoFilters, Boolean rendered, Boolean include) {
      String q = qb.crossFilterIdToQuery + (include ? ' ' : ' NOT ') + 'IN (SELECT ' + qb.crossFilterId + ' FROM ' + qb.crossFilterObj;
      if(!this.filters.isEmpty()) q += ' WHERE ' + String.join(filters, ' AND ');
      q += ')';
      if ((!filters.isEmpty() || renderedIfNoFilters) && rendered) parent.addUntyped(q);
      qb.crossFilterId = null;
      qb.crossFilterIdToQuery = null;
      qb.crossFilterObj = null;
      return parent;
    }

    private String getOperator(QBOp op) {
      return qb.qbop2operator.get(op);
    }
  }

  public static String getValue(Object v) {
    if(
      v instanceof List<String> ||
      v instanceof List<Id> ||
      v instanceof List<Date> ||
      v instanceof List<Datetime> ||
      v instanceof List<Decimal> ||
      v instanceof List<Double> ||
      v instanceof List<Integer> ||
      v instanceof Set<String> ||
      v instanceof Set<Id> ||
      v instanceof Set<Date> ||
      v instanceof Set<Datetime> ||
      v instanceof Set<Decimal> ||
      v instanceof Set<Double> ||
      v instanceof Set<Integer>
    ) return buildInFilter(v);
    else if(v instanceof String || v instanceof Id) return '\'' + String.escapeSingleQuotes((String) v) + '\'';
    //YYYY-MM-dd
    else if(v instanceof Date) return Datetime.newInstance((Date) v, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
    else if(v instanceof Datetime) return ((Datetime) v).format('YYYY-MM-dd\'T\'HH:mm:ss.SSSZ');
    else if(v != null) return String.valueOf(v);
    else return null;
  }

  public static QueryBuilder newInstance(String obj, String[] fields, String[] fields2) {
    String[] fL = new List<String>(fields);
    fL.addAll(fields2);
    return newInstance(obj, fL);
  }

  public static QueryBuilder newInstance(String obj, String[] fields) {
    QueryBuilder qb = new QueryBuilder(obj, fields);
    return qb;
  }

  public QueryBuilder(String obj, String[] fields) {
    this.orderBy = new String[]{};
    this.obj = obj;
    this.fields = U.toList(U.toSet(fields));
    this.rootFilter = new FilterBuilder(this, 'and', null);
  }

  public FilterBuilder beginFilter() {
    return rootFilter;
  }

  public QueryBuilder withId(Id oId) {
    rootFilter.add('Id', QBOp.QEQUAL, oId);
    return this;
  }

  public QueryBuilder orderBy(String[] orderBy) {
    this.orderBy = orderBy;
    return this;
  }

  public QueryBuilder setLimit(Integer qlimit) {
    this.qlimit = qLimit;
    return this;
  }

  public String getQuery() {
    String q = 'SELECT ' + String.join(fields, ', ') + ' FROM ' + obj;
    if(!rootFilter.filters.isEmpty()) q += ' WHERE ' + String.join(rootFilter.filters, ' AND ');
    if(!orderBy.isEmpty()) q += ' ORDER BY ' + String.join(orderBy, ', ');
    if(qLimit != null) q += ' LIMIT ' + String.valueOf(qLimit);
    rootFilter = null;
    return q;
  }

  /**
   * Costruisce un in filter. Il codice osceno Ã¨ dovuto alle limitazioni nel casting di Salesforce. Altrimenti si poteva
   * scrivere in 3 righe
   *
   * @param      x     Una lista o un set di primitive
   * @return     La lista di valori, racchiusa tra parentesi, correttamente formattata ed escapata e
   * pronta per essere usata nella query
   */
  private static String buildInFilter(Object x) {
    String[] res = new String[]{};
    String sep = '';

    if(x instanceof Set<String>) {
      sep = '\'';
      for(String v : (Set<String>) x) {
        res.add(String.escapeSingleQuotes(v));
      }
    } else if(x instanceof Set<Id>) {
      sep = '\'';
      for(Id v : (Set<Id>) x) {
        res.add(String.escapeSingleQuotes(v));
      }
    } else if(x instanceof List<String>) {
      sep = '\'';
      for(String v : (List<String>) x) {
        res.add(String.escapeSingleQuotes(v));
      }
/* APPARENTEMENTE UNA LISTA DI ID VIENE INTERPRETATA CMQ COME UNA LISTA DI STRING...
    } else if(x instanceof List<Id>) {
      sep = '\'';
      for(Id v : (List<Id>) x) {
        res.add(String.escapeSingleQuotes(v));
      }
*/
    } else if(x instanceof List<Date>) {
      for(Date v : (List<Date>) x) {
        res.add(getValue(v));
      }
    } else if(x instanceof List<Datetime>) {
      for(Datetime v : (List<Datetime>) x) {
        res.add(getValue(v));
      }
    } else if(x instanceof List<Decimal>) {
      for(Decimal v : (List<Decimal>) x) {
        res.add(getValue(v));
      }
/* APPARENTEMENTE UNA LISTA DI DOUBLE VIENE INTERPRETATA CMQ COME UNA LISTA DI DECIMAL...
    } else if(x instanceof List<Double>) {
      for(Double v : (List<Double>) x) {
        res.add(getValue(v));
      }
*/
    } else if(x instanceof Set<Date>) {
      for(Date v : (Set<Date>) x) {
        res.add(getValue(v));
      }
    } else if(x instanceof Set<Datetime>) {
      for(Datetime v : (Set<Datetime>) x) {
        res.add(getValue(v));
      }
    } else if(x instanceof Set<Decimal>) {
      for(Decimal v : (Set<Decimal>) x) {
        res.add(getValue(v));
      }
    } else if(x instanceof Set<Double>) {
      for(Double v : (Set<Double>) x) {
        res.add(getValue(v));
      }
/* APPARENTEMENTE UNA LISTA DI INTEGER VIENE INTERPRETATA CMQ COME UNA LISTA DI DECIMAL...
    } else if(x instanceof List<Integer>) {
      for(Integer v : (List<Integer>) x) {
        res.add(getValue(v));
      }
*/
    } else if(x instanceof Set<Integer>) {
      for(Integer v : (Set<Integer>) x) {
        res.add(getValue(v));
      }
    }

    return '(' + sep + String.join(res, sep + ',' + sep) + sep + ')';
  }
}