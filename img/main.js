import { createApp } from 'vue'
import App from './App.vue'
import Konva from 'konva';
import Big from 'big.js';
import {vector, matrix_2by2} from './math/vector'

createApp(App).mount('#app')

// Konva init
const width = window.innerWidth
const height = window.innerHeight

var stage = new Konva.Stage({
    container: 'box',
    width: width,
    height: height
})

var layer = new Konva.Layer()

function create_group_base(cex, cey, rad, cecol, cescol, tecol, data, moble) {
    var group_base = new Konva.Group({
        draggable: moble,
        name: 'group_base'
    })
    var circle = new Konva.Circle({
        x: cex,
        y: cey,
        radius: rad,
        fill: cecol,
        stroke: cescol,
        strokeWidth: 0.7
    })
    var text = new Konva.Text({
        x: circle.x() - circle.radius(),
        y: circle.y() - circle.radius(),
        text: data,
        fontSize: rad + 4,
        fill: tecol,
        padding: ((rad + 4)/2) - (String(data).length - 1) * 4,
        align: 'center',
    })
    group_base.add(circle)
    group_base.add(text)
    return group_base
}

function create_arrow(arx, ary, pox, poy, col, arrstyle = true){
    let arrsize = (arrstyle) ? 10 : 0
    let arrow = new Konva.Arrow({
        points: [arx, ary, pox, poy],
        pointerLength: arrsize,
        pointerWidth: arrsize,
        fill: col,
        stroke: col,
        strokeWidth: 2
    })
    return arrow
}

function create_label(weight, labx, laby) {
    let weight_label = new Konva.Label({
        x: labx,
        y: laby,
        opacity: 0.8
    })
    weight_label.add(
        new Konva.Tag({
            fill: theme[0]
        })
    )
    weight_label.add(
        new Konva.Text({
          text: weight,
          fontFamily: 'Calibri',
          fontSize: visu_bse_size * 0.8,
          padding: 5,
          fill: theme[3]
        })
    );
    return weight_label
}

stage.add(layer)
layer.draw()

//
const theme = ['hsl(306, 25%, 92%)','hsl(230, 35%, 79%)','hsl(264, 25%, 63%)','hsl(296, 39%, 31%)'];
// undigraph:无权, digraph:有权, undirected:无向, directed:有向
// snum_type 1:无权无向, 2:无权有向, 3:有权无向, 4:有权有向
const undigraph = 'undigraph', digraph = 'digraph', undirected = 'undirected', directed = 'directed', nullnode = null;
const visu_bse_size = 25
const dfs = 'dfs', bfs = 'bfs', maxpq = 'maxpq', minpq = 'minpq'
// const safariAgent = userAgentString.indexOf("Safari") > -1;

class Stack {
    constructor() {
        this.stack_list = []
    }
    list() {
        return this.stack_list
    }
    push(item) {
        this.stack_list.unshift(item)
    }
    pop() {
        return this.stack_list.shift()
    }
    top() {
        return this.stack_list[0]
    }
    size() {
        return this.stack_list.length
    }
    is_empty() {
        return this.stack_list.length == 0
    }
}
class Queue {
    constructor() {
        this.queue_list = []
    }
    list() {
        return this.queue_list
    }
    en(item) {
        this.queue_list.push(item)
    }
    de() {
        return this.queue_list.shift()
    }
    is_has(val) {
        return this.queue_list.includes(val)
    }
    size() {
        return this.queue_list.length
    }
    is_empty() {
        return this.queue_list.length == 0
    }
}
class Priority_queue {
    /** @param {*} sort_rule min: (a, b) => { return a - b } */
    constructor(sort_rule) {
        this.queue_list =  []
        this.sort_rule = sort_rule
        this.sort()
    }
    list() {
        return this.queue_list
    }
    insert(item) {
        this.queue_list.push(item)
        this.sort()
    }
    sort() {
        this.queue_list.sort(this.sort_rule)
    }
    del_m() {
        return this.queue_list.shift()
    }
    get_m(index = 0) {
        return this.queue_list[index]
    }
    is_empty() {
        return this.queue_list.length == 0
    }
    make_empty() {
        this.queue_list = []
    }
}
class Priority_queue_index {
    /** @param {*} sort_rule min of item : (a, b) => a[1] - b[1] */
    constructor(sort_rule) {
        this.sort_rule = sort_rule
        this.queue_maps = new Map()
    }
    list() {
        return this.queue_maps
    }
    set(k, item) {
        this.queue_maps.set(k, item)
        this.sort()
    }
    /** @returns 是否存在索引为 k 的元素 */
    contains(k) {
        return this.queue_maps.has(k)
    }
    remove(k) {
        return this.queue_maps.delete(k)
    }
    sort() {
        this.queue_maps = new Map([...this.queue_maps].sort(this.sort_rule))
    }
    /** @returns 指定元素和索引 (默认顶部) */
    get_m(index = 0) {
        let top = [...this.queue_maps][index]
        return {k:top[0], v:top[1]}
    }
    get_m_v(index = 0) {
        return this.get_m(index).v
    }
    get_m_k(index = 0) {
        return this.get_m(index).k
    }
    /** @returns 顶部元素和索引 (删除) */
    del_m() {
        let lists = [...this.queue_maps]
        let top = lists.shift()
        this.queue_maps = new Map(lists)
        return {k:top[0], v:top[1]}
    }
    del_m_v() {
        return this.del_m().v
    }
    del_m_k() {
        return this.del_m().k
    }
    size() {
        return this.queue_maps.size
    }
    is_empty() {
        return this.size() == 0
    }
}
class Node{
    constructor(group) {
        this.group = group
        this.edge_list = []
        this.arrow_list = []
    }
}
class D_Node extends Node{
    constructor(group) {
        super(group)
        this.weight_list = []
        this.label_list = []
    }
}
class Edge_Node {
    constructor(v, w) {
        this.v = v
        this.w = w
    }
    rotate() {
        return new Edge_Node(this.w, this.v)
    }
    find_same(list) {
        let r_edge = this.rotate()
        return list.findIndex((val) => r_edge.v == val.v && r_edge.w == val.w )
    }
    other(v) {
        return (this.v == v) ? this.w : this.v
    }
}
class D_Edge_Node extends Edge_Node{
    constructor(v, w, weight) {
        super(v, w)
        this.weight = weight
    }
    rotate() {
        return new D_Edge_Node(this.w, this.v, this.weight)
    }
}
class D_Edge_Marked {
    constructor(graph, s_ver) {
        this.s = s_ver
        this.last_e = graph.set_marked(nullnode)
        this.dist_e = graph.set_marked(Number.POSITIVE_INFINITY)
    }
    /** @returns s 到 v 的最后一条边 */
    edge(v) {
        return this.last_e.get(v)
    }
    /** @returns s 到 v 的距离 or 权重和 */
    dist(v) {
        return this.dist_e.get(v)
    }
    updata_e(v, e) {
        this.last_e.set(v, e)
    }
    updata_d(v, d) {
        this.dist_e.set(v, d)
    }
    updatas(v, e, d) {
        this.updata_e(v, e)
        this.updata_d(v, d)
    }
}
class D_N_Edge_Marked extends D_Edge_Marked{
    constructor(graph, s_ver) {
        super(graph, s_ver)
        this.negative_cycle = nullnode
    }
    /** 如果路径栈非空则设置负权重环 */
    set_negative_cycle(cycle_stack) {
        if (!cycle_stack.is_empty()) {
            this.negative_cycle = cycle_stack
        }
    }
    is_negative_cycle() {
        return this.negative_cycle != nullnode
    }
}
class Graph_Type {
    constructor(snum_type) {
        [this.wtype, this.dtype] = this.graph_type_simple(snum_type)
        this.snum_type = snum_type
    }
    graph_type_simple(snum_type) {
        let wd = []
        switch (snum_type) {
            case 1:{ wd = [undigraph, undirected];   break;}
            case 2:{ wd = [undigraph, directed];     break;}
            case 3:{ wd = [digraph, undirected];     break;}
            case 4:{ wd = [digraph, directed];       break;}
        }
        return wd
    }
    get_snum_type() {
        return this.snum_type
    }
    /** @returns 是有向图吗 */
    is_directed() {
        return this.dtype == directed
    }
    /** @returns 是无向图吗 */
    is_undirected() {
        return this.dtype == undirected
    }
    /** @returns 是加权图吗 */
    is_weighted() {
        return this.wtype == digraph
    }
    /** @returns 是无权图吗 */
    is_unweighted() {
        return this.wtype == undigraph
    }
}

class Graph{
    constructor(snum_type) {
        // this.graph_type = new Graph_Type(snum_type)
        //[this.wtype, this.dtype] = graph_type_simple(snum_type)
        /** @returns 图的所有顶点 keys() 和相关值的 Map 表 */
        this.adj_list = new Map()
        this.graph_type = new Graph_Type(snum_type)
    }
    add_vertex(v) {
        
        let group = create_group_base(width/2, height/2, visu_bse_size, theme[0], theme[1], theme[2], v, true)
        if (this.graph_type.is_weighted()) {
            this.adj_list.set(v,new D_Node(group))
        } else {
            this.adj_list.set(v,new Node(group))
        }
    }
    add_edge(v ,w, weight = 0) {
        let v_ver = this.adj_list.get(v)
        let w_ver = this.adj_list.get(w)
        
        let arrstyle = (this.graph_type.is_undirected()) ? false : true

        v_ver.edge_list.push(w)
        arrow_list_push_arr(v_ver, w_ver, arrstyle)

        if (this.graph_type.is_undirected()){
            w_ver.edge_list.push(v)
            arrow_list_push_arr(w_ver, v_ver, arrstyle)
        }

        if (this.graph_type.is_weighted()) {
            v_ver.weight_list.push(weight)
            label_list_push_lab(v_ver, w_ver, weight)

            if (this.graph_type.is_undirected()){
                w_ver.weight_list.push(weight)
                label_list_push_lab(w_ver, v_ver, weight)
            }
        }
    }
    del_edge(v, w) {
        let v_ver = this.adj_list.get(v)
        let w_ver = this.adj_list.get(w)
        let index_v, index_w

        index_v = list_remove_val(v_ver.edge_list, w)
        list_remove_index(v_ver.arrow_list, index_v).destroy();

        if (this.graph_type.is_undirected()){
            index_w = list_remove_val(w_ver.edge_list, v)
            list_remove_index(w_ver.arrow_list, index_w).destroy();
        }

        if (this.graph_type.is_weighted()) {
            list_remove_index(v_ver.weight_list, index_v)
            list_remove_index(v_ver.label_list, index_v).destroy()

            if (this.graph_type.is_undirected()){
                list_remove_index(w_ver.weight_list, index_w)
                list_remove_index(w_ver.label_list, index_w).destroy()
            }
        }
    }
    visualization() {
        layer_add_list(this.get_all_group_list())
        layer_add_list(this.get_all_arrow_list())
        if (this.graph_type.is_weighted()) {
            layer_add_list(this.get_all_label_list())
        }
        drag(this)
    }
    vn() {
        return this.adj_list.size
    }
    en() {
        let len = this.get_all_edge_list().length
        return (this.graph_type.is_undirected()) ? new Big(len).div(2).toNumber() : len
    }
    out_degree(v) {
        return this.get_edge_list(v).length
    }
    in_degree(v) {
        return this.reverse().get_edge_list(v).length
    }
    degree(v) {
        
        return (this.graph_type.is_directed()) ? this.out_degree(v) + this.in_degree(v) : this.out_degree(v)
    }
    /** @returns 复制一个无边的当前图 */
    copy_no_edge_graph() {
        let g_lo = new Graph(this.graph_type.get_snum_type())
        for (let key of this.adj_list.keys()) {
            g_lo.add_vertex(key)
        }
        return g_lo
    }
    reverse() {
        if (this.graph_type.is_directed()) {
            let g_lo = this.copy_no_edge_graph()
            for (let [key_v, val] of this.adj_list) {
                for (const key_w in val.edge_list) {
                    if (this.graph_type.is_weighted()) {
                        g_lo.add_edge(val.edge_list[key_w], key_v, val.weight_list[key_w])
                    } else {
                        g_lo.add_edge(val.edge_list[key_w], key_v)
                    }
                }
            }
            return g_lo
        }
        return this
        
    }
    get_vals(v) {
        return this.adj_list.get(v)
    }
    get_group(v) {
        return this.adj_list.get(v).group
    }
    /** @returns v 连通的顶点列表 */
    get_edge_list(v) {
        return this.adj_list.get(v).edge_list
    }
    get_arrow_list(v) {
        return this.adj_list.get(v).arrow_list
    }
    get_label_list(v) {
        return this.adj_list.get(v).label_list
    }
    get_weight_list(v) {
        return this.adj_list.get(v).weight_list
    }
    get_all_group_list() {
        let count = []
        this.adj_list.forEach(val => count.push(val.group))
        return count
    }
    get_all_edge_list(flat = true) {
        let count = []
        this.adj_list.forEach(val => count.push(val.edge_list))
        return (flat == true) ? count.flat() : count
    }
    get_all_arrow_list(flat = true) {
        let count = []
        this.adj_list.forEach(val => count.push(val.arrow_list))
        return (flat == true) ? count.flat() : count
    }
    get_all_label_list(flat = true) {
        let count = []
        this.adj_list.forEach(val => count.push(val.label_list))
        return (flat == true) ? count.flat() : count
    }
    /** @returns v 连通的边列表 Edge_Node : {v, w, !weight} */
    get_edge_obj_list(v) {
        let count = []
        this.get_edge_list(v).forEach((v_w, index) => {
            let t = (this.graph_type.is_weighted()) ? new D_Edge_Node(v, v_w, this.get_weight_list(v)[index]) : new Edge_Node(v, v_w)
            count.push(t)
        })
        return count
    }
    /** @returns 图的所有边列表 (默认去除无向图重复边)*/
    get_edge_obj_all_list(nosame = true) {
        let count = []
        for (const ver of this.adj_list.keys()) {
            count.push(this.get_edge_obj_list(ver))
        }
        let f_count = count.flat()
        if (nosame) {
            for (const edge of f_count) {
                let index = edge.find_same(f_count)
                if (index != -1) {
                    f_count.splice(index, 1)
                }
            }
        }
        return f_count
    }
    get_edge_path_obj_list(path = [nullnode]) {
        let count = []
        while (path.length > 1) {
            let [v, w] = [path.shift(), path[0]]
            let index =  this.get_edge_list(v).findIndex(val => val == w)
            let t = (this.graph_type.is_weighted()) ? new D_Edge_Node(v, w, this.get_weight_list(v)[index]) : new Edge_Node(v, w)
            count.push(t)
        }
        return count
    }
    /** @returns 图的首个顶点 (最先加入) */
    get_head_ver() {
        return [...this.adj_list.keys()][0]
    }
    get_all_weight_list() {
        let count = []
        this.get_edge_obj_all_list().forEach(e => {
            count.push(e.weight)
        })
        return count
    }
    find_point_v_of_ver(v) {
        let count = []
        for (const [key, val] of this.adj_list){
            let index = val.edge_list.findIndex((value) => { return value == v })
            if (index != -1) {
                count.push(key)
            }
        }
        return count
    }
    /**
     * @param {*} init_val false
     * @returns 当前所有顶点和默认值构成的 Map
     */
    set_marked(init_val = false) {
        return new Map([...this.adj_list].map(([k, v]) => [k, init_val]))
    }

    /**
     * 1.根据规则取其中的下一个顶点并标记它
     * 规则：dfs 最早加入的顶点, bfs 最晚加入的顶点
     * 2.将 v 的所有相邻而又未被标记的顶点加入数据结构
     */
    /** 找到所有起点为 s 的路径 edge_to.keys()是和 s 连通的所有顶点(不包括 s) */
    dfs(s) {
        let marked = this.set_marked()
        let edge_to = new Map()
        this.#dfs_base(s, marked, edge_to)
        return edge_to
    }
    #dfs_base(s, marked, edge_to) {
        marked.set(s, true)
        let v = s
        for (let w of this.get_edge_list(s).values()) {
            if (!marked.get(w)) {
                edge_to.set(w, v)
                this.#dfs_base(w, marked, edge_to)
            }
        }
    }
    /** @returns 所有起点为 s 的路径(最短路径) */
    bfs(s) {
        let marked = this.set_marked()
        let edge_to = new Map()
        this.#bfs_base(s, marked, edge_to)
        return edge_to
    }
    #bfs_base(s, marked, edge_to) {
        let queue_lo = new Queue()
        queue_lo.en(s)
        marked.set(s, true)
        let v = s
        while (!queue_lo.is_empty()) {
            v = queue_lo.de()
            for (let w of this.get_edge_list(v).values()) {
                if (!marked.get(w)) {
                    edge_to.set(w, v)
                    marked.set(w, true)
                    queue_lo.en(w)
                }
            }
        }
    }
    use_path_tree(ptype, s) {
        switch (ptype) {
            case dfs:{return this.dfs(s)}
            case bfs:{return this.bfs(s)}
        }
    }
    // 
    /** 是否存在从 s 到 v 的路径 */
    has_path_to(s, v, ptype = dfs) {
        let edge_to = this.use_path_tree(ptype, s)
        return (s == v) ? true : [...edge_to.keys()].includes(v)
    }
    
    /** s 到 v 的路径 最短路径 (所含边数最少) */
    path_to_fs(s, v, ptype = bfs) {
        if (!this.has_path_to(s, v, ptype)) {
            return null
        }
        let edge_to = this.use_path_tree(ptype, s)
        return edge_to_path_traversal(s, v, edge_to)
    }
    
    /** @returns 连通分量索引表 (自动区分无向图或有向图) */
    connected_components() {
        return (this.graph_type.is_undirected()) ? this.#cc() : this.#scc_kosaraju()
    }

    /**
     * 根据 order_rule 循环查找每个没有被标记的顶点并递归调用 dfs() 来标记和它相邻的所有顶点
     * @param {*} order_rule 默认是无向图, 反向图的revpost是有向图
     * @returns cc_id_list 保存同一个连通分量中的顶点和连通分量的标识符
     */
    #cc(order_rule = this.adj_list.keys()) {
        let marked = this.set_marked()
        let cc_id_list = this.set_marked()
        let count = 0
        for (const ver of order_rule) {
            if (!marked.get(ver)) {
                count += 1
                this.#dfs_base_cc(ver, marked, cc_id_list, count)
            }
        }
        return cc_id_list
    }
    #dfs_base_cc(v, marked, cc_id_list, count) {
        marked.set(v, true)
        cc_id_list.set(v, count)
        for (let w of this.get_edge_list(v).values()) {
            if (!marked.get(w)) {
                this.#dfs_base_cc(w, marked, cc_id_list, count)
            }
        }
    }
    /** v 和 w 连通吗 */
    connected(v, w) {
        let cc_id_list = this.connected_components()
        return cc_id_list.get(v) == cc_id_list.get(w)
    }
    /** @returns 连通分量数 */
    connected_count() {
        return Math.max(...[...this.connected_components().values()])
    }

    /**
     * 前序：递归前顶点入队
     * 后序：递归后顶点入队
     * 逆后序：递归后顶点压栈
     */
    depth_first_order() {
        let marked = this.set_marked()
        let pre = new Queue()
        let post = new Queue()
        let revpost = new Stack()
        for (const ver of this.adj_list.keys()) {
            if (!marked.get(ver)) {
                this.#dfs_base_dfo(ver, marked, pre, post, revpost)
            }
        }
        return {
            pre, post, revpost
        }
    }
    #dfs_base_dfo(v, marked, pre, post, revpost) {
        pre.en(v)
        marked.set(v, true)
        for (let w of this.get_edge_list(v).values()) {
            if (!marked.get(w)) {
                this.#dfs_base_dfo(w, marked, pre, post, revpost)
            }
        }
        post.en(v)
        revpost.push(v)
    }
    /**
     * depth_first_order 得到的反向图 GR 的逆后序排列
     * 使用 revpost 进行连通分量的深度优先搜索
     */
    #scc_kosaraju() {
        let {revpost} = this.reverse().depth_first_order()
        return this.#cc(revpost.list())
    }

    /** @returns 返回环的路径 */
    d_cycle_path() {
        let on_stack = this.set_marked()
        let marked = this.set_marked()
        let edge_to = new Map()
        let cycle = new Stack()
        for (const ver of this.adj_list.keys()) {
            if (!marked.get(ver)) {
                this.#dfs_d_cycle(ver, ver, marked, edge_to, on_stack, cycle)
            }
        }
        return cycle
    }
    /** condition = () ? 无向图 : 有向图 */
    #dfs_d_cycle(v, u, marked, edge_to, on_stack, cycle) {
        on_stack.set(v, true)
        marked.set(v, true)
        for (const w of this.get_edge_list(v).values()) {
            let condition = (this.graph_type.is_undirected() ) ? w != u : on_stack.get(w)
            if (!cycle.is_empty()) {
                return cycle
            } else if (!marked.get(w)) {
                edge_to.set(w, v)
                this.#dfs_d_cycle(w, v, marked, edge_to, on_stack, cycle)
            } else if (condition) {
                edge_to_path_traversal(w, v, edge_to, cycle)
                cycle.list().push(w)
            }
        }
        on_stack.set(v, false)
    }
    has_cycle() {
        return !this.d_cycle_path().is_empty()
    }

    /**
     * 拓扑排序
     * @returns 所有的有向边均从排在前面的元素指向排在后面的元素
     */
    topological() {
        return (!this.has_cycle() && this.graph_type.is_directed()) ? this.depth_first_order().revpost : nullnode
    }
    is_dag() {
        return this.topological() != nullnode
    }

    
    /**
     * 从默认首个节点起处理
     * 标记节点 v 将未标记的连通节点 w 的边加入优先队列
     * 取得当前最小权重的边, 如果未失效就加入最小生成树
     * 重复标记直到队列为空
     */
    /** 最小生成树的 Prim 算法 (保留失效边) */
    mst_prim(s_ver = this.get_head_ver()) {
        let marked = this.set_marked()
        let pq = new Priority_queue((a, b) => a.weight - b.weight)
        let mst = new Queue()
        this.#prim_visit(s_ver, marked, pq)
        while (!pq.is_empty()) {
            let e_min = pq.del_m()
            let [v, w] = [e_min.v, e_min.w]
            if (marked.get(v) && marked.get(w)) {
                continue
            }
            mst.en(e_min)
            if (!marked.get(v)) {
                this.#prim_visit(v, marked, pq)
            }
            if (!marked.get(w)) {
                this.#prim_visit(w, marked, pq)
            }
        }
        return mst
    }
    #prim_visit(ver, marked, pq) {
        marked.set(ver, true)
        for (const e of this.get_edge_obj_list(ver)) {
            if (!marked.get(e.other(ver))) {
                pq.insert(e)
            }
        }
    }

    /**
     * 按照边的权重进行最小优先队列处理
     * 如果加入的边不会与已有边构成环, 就将边加入最小生成树中
     * 直到树中含有 V-1条边
     */
    /** 最小生成树的 Kruskal 算法 */
    mst_kruskal() {
        let pq = new Priority_queue((a, b) => a.weight - b.weight)
        let mst = new Queue()
        this.get_edge_obj_all_list().forEach(e => pq.insert(e))
        let ga_lo = this.copy_no_edge_graph()
        while (!pq.is_empty() && mst.size() < ga_lo.vn() - 1) {
            let e_min = pq.del_m()
            ga_lo.add_edge(e_min.v, e_min.w, e_min.weight)
            if (ga_lo.has_cycle()) {
                ga_lo.del_edge(e_min.v, e_min.w)
            } else {
                mst.en(e_min)
            }
        }
        return mst
    }

    /**
     * 每次将一条边添加到假设的最小生成树
     * 如果因此形成一个环则删去环中权重最大的边
     */
    /** 最小生成树的 Vyssotsky 算法 */
    mst_vyssotsky() {
        let pq = new Priority_queue((a, b) => b.weight - a.weight)
        let mst = new Queue()
        let ga_lo = this.copy_no_edge_graph()
        for (const e of this.get_edge_obj_all_list()) {
            ga_lo.add_edge(e.v, e.w, e.weight)
            if (ga_lo.has_cycle()) {
                let cycle_e_list = this.get_edge_path_obj_list(ga_lo.d_cycle_path().list())
                cycle_e_list.forEach(e => pq.insert(e))
                let e_max = pq.del_m()
                ga_lo.del_edge(e_max.v, e_max.w)
                pq.make_empty()
            }
        }
        ga_lo.get_edge_obj_all_list().forEach(e => mst.en(e))
        return mst
    }

    /**
     * 从默认起点 s 起处理 (第一个 w 等于 s)
     * 记录: 起点到节点 w 的距离并加入优先队列
     * 取得当前最小距离节点 v, 遍历所有连通的边以及对应节点 w, 如果满足更优距离就更新记录并保存当前边
     * 更优距离: 起点到 w 的距离 <= 起点到 v 的距离 + v 到 w 的权重
     * 重复记录直到队列为空
     */
    /** 最短路径的 Dijkstra 算法 (仅正权重) */
    spt_dijkstra(s_ver = this.get_head_ver()) {
        if (this.has_negative_weight()) {
            return nullnode
        }
        let s_to = new D_Edge_Marked(this, s_ver)
        let pq = new Priority_queue_index((a, b) => a[1] - b[1])
        s_to.updata_d(s_ver, 0)
        pq.set(s_ver, 0)
        // 无环时使用拓扑排序进行遍历效率更高
        if (!this.has_cycle()) {
            for (const ver of this.topological().list()) {
                this.relax(ver, s_to, pq)
            }
        } else {
            while (!pq.is_empty()) {
                this.relax(pq.del_m_k(), s_to, pq)
            }
        }
        return s_to
    }
    relax(v, s_to, pq) {
        for (const e of this.get_edge_obj_list(v)) {
            let w = e.w
            if (s_to.dist(w) > s_to.dist(v) + e.weight) {
                s_to.updatas(w, e, s_to.dist(v) + e.weight)
                pq.set(w, s_to.dist(w))
            }
        }
    }
    has_path_to_sp(s, v) {
        let s_to = this.spt_dijkstra(s)
        return (s_to != nullnode) ? s_to.dist(v) < Number.POSITIVE_INFINITY : false
    }
    /** s 到 v 的最短路径 (总权重最小) */
    path_to_sp(s, v) {
        if (!this.has_path_to_sp(s, v)) {
            return null
        }
        let s_to = this.spt_dijkstra(s)
        return s_to_path_traversal(s, v, s_to)
    }
    has_negative_weight() {
        return Math.sign(Math.min(...this.get_all_weight_list())) == -1
    }

    /**
     * fix
     */
    /** 最短路径的 Bellman-Ford 算法 (含负权重) (队列实现) */
    spt_bellman_ford(s_ver = this.get_head_ver()) {
        let s_to = new D_N_Edge_Marked(this, s_ver)
        let q_re = new Queue()
        let count = {relax_times: 0}
        s_to.updata_d(s_ver, 0)
        q_re.en(s_ver)
        while (!q_re.is_empty() && !s_to.is_negative_cycle()) {
            let v = q_re.de()
            this.relax_bmf(v, s_to, q_re, count)
        }
        return s_to
    }
    relax_bmf(v, s_to, q_re, count) {
        for (const e of this.get_edge_obj_list(v)) {
            let w = e.w
            if (s_to.dist(w) > s_to.dist(v) + e.weight) {
                s_to.updatas(w, e, s_to.dist(v) + e.weight)
                if (!q_re.is_has(w)) {
                    q_re.en(w)
                }
            }
            count.relax_times += 1
            if (count.relax_times % this.vn() == 0) {
                s_to.set_negative_cycle(this.#find_negative_cycle(s_to))
            }
        }
    }
    /** @returns 负权重环 (不存在则返回空栈) */
    #find_negative_cycle(s_to) {
        let spt_n = this.copy_no_edge_graph()
        for (const ver of this.adj_list.keys()) {
            let e = s_to.edge(ver)
            if (e != nullnode) {
                spt_n.add_edge(e.v, e.w, e.weight)
            }
        }
        return spt_n.d_cycle_path()
    }
    /** 是否含有负权重环 */
    has_negative_cycle(s_ver = this.get_head_ver()){
        return this.spt_bellman_ford(s_ver).is_negative_cycle()
    }
    has_path_to_sp_bmf(s, v) {
        let s_to = this.spt_bellman_ford(s)
        return s_to.dist(v) < Number.POSITIVE_INFINITY
    }
    /** 负权重环不可达时 s 到 v 的最短路径 (总权重最小) */
    path_to_sp_bmf(s, v) {
        if (!this.has_path_to_sp_bmf(s, v) && this.has_negative_cycle(s)) {
            return null
        }
        let s_to = this.spt_bellman_ford(s)
        return s_to_path_traversal(s, v, s_to)
    }
}


var g = new Graph(4)

const vl = ['1','2','3','4','5','6','7']
for (const key in vl) {
    g.add_vertex(vl[key])
}
g.add_edge('1','2',17)
// //g.add_edge('1','2')
g.add_edge('1','3',21)
g.add_edge('3','4',25)
g.add_edge('2','4',10)
g.add_edge('3','5',33)
g.add_edge('6','1',13)
g.add_edge('2','5',31)
g.add_edge('6','3',29)
g.add_edge('6','2',27)
g.add_edge('4','7',39)
g.add_edge('5','7',45)
// g.add_edge('7','1',-44)
g.visualization()
console.log(g)
// g.del_edge('3','4')
console.log(g.dfs('1'))
console.log(g.has_path_to('1', '6'))
console.log(g.has_path_to('1', '7'))
//console.log(g.bfs('1'))
//console.log(g.path_to('1', '5', bfs))
console.log(g.connected_components());
console.log(g.d_cycle_path());
// console.log(g.has_cycle());
console.log(g.topological());
console.log(g.dfs('1'));
console.log(g.get_edge_obj_all_list());
console.log(g.mst_prim());
console.log(g.mst_kruskal());
console.log(g.mst_vyssotsky());
console.log(g.spt_dijkstra());
console.log(g.path_to_sp('1','7'));

console.log(g.spt_bellman_ford());
console.log(g.has_negative_cycle());
console.log(g.path_to_sp_bmf('1','7'));
console.log(g.has_negative_weight());


/** 遍历 s_to 找到一条从 s_ver 到 e_ver 的路径栈 */
function s_to_path_traversal(s_ver, e_ver, s_to, stack_lo = new Stack()) {
    for (let e = s_to.edge(e_ver); e != nullnode; e = s_to.edge(e.v)) {
        if (e == undefined) break
        stack_lo.push(e.w)
    }
    stack_lo.push(s_ver)
    return stack_lo
}

/** 遍历 edge_to 找到一条从 s_ver 到 e_ver 的路径栈 */
function edge_to_path_traversal(s_ver, e_ver, edge_to, stack_lo = new Stack()){
    for (let ver = e_ver; ver != s_ver ; ver = edge_to.get(ver)) {
        if (ver == undefined) break
        stack_lo.push(ver)
    }
    stack_lo.push(s_ver)
    return stack_lo
}

/** @returns 被删除元素的索引 */
function list_remove_val(list, val) {
    let index = list.findIndex(value => value == val)
    if (index != -1) list.splice(index, 1)
    return index
}
/** @returns 被删除元素 */
function list_remove_index(list, index) {
    return list.splice(index, 1)[0]
}

function layer_add_list(list) {
    if (list.length != 0) layer.add(...list)
}

function arrow_list_push_arr(v_ver, w_ver, arrstyle) {
    let [gr1, gr2] = get_arrow_xy(v_ver.group, w_ver.group)
    let arr = create_arrow(...gr1.value(), ...gr2.value(), theme[2], arrstyle)
    v_ver.arrow_list.push(arr)
}

function label_list_push_lab(v_ver, w_ver, weight) {
    let [gr1, gr2] = get_arrow_xy(v_ver.group, w_ver.group)
    let lab_xy = get_label_xy(gr1, gr2)
    let lab = create_label(weight, ...lab_xy.value())
    v_ver.label_list.push(lab)
}

function get_group_current_xy(gr1){
    let gr1_cir = new vector(gr1.children[0].x(),gr1.children[0].y())
    let gr1_group = new vector(gr1.x(),gr1.y())
    return new vector(...new matrix_2by2().addition(gr1_cir, gr1_group))
}

function get_arrow_xy(group1, group2, offex = 4) {
    let gr1 = get_group_current_xy(group1)
    let gr2 = get_group_current_xy(group2)
    let [in_gr2_arc, in_gr1_arc] = [Math.atan2(gr1.y - gr2.y,gr1.x - gr2.x), Math.atan2(gr2.y - gr1.y,gr2.x - gr1.x)]
    let rad = group1.children[0].radius() + offex
    let gr1_ring = new vector(gr1.x + rad * Math.cos(in_gr1_arc), gr1.y + rad * Math.sin(in_gr1_arc))
    let gr2_ring = new vector(gr2.x + rad * Math.cos(in_gr2_arc), gr2.y + rad * Math.sin(in_gr2_arc))
    return [gr1_ring, gr2_ring]
}

function get_label_xy(vec1, vec2) {
    let [x_lo, y_lo] = new matrix_2by2().addition(vec1, vec2)
    return new vector(new Big(x_lo).div(2).toNumber(), new Big(y_lo).div(2).toNumber())
}

// 可视化：更新一个结点下的所有边
function darg_updata(data, g_lo) {
    let gr1 = g_lo.get_group(data)
    let edge_list_lo = g_lo.get_edge_list(data)
    let arrow_list_lo = g_lo.get_arrow_list(data)

    for (const key in edge_list_lo) {
        let gr2 = g_lo.get_group(edge_list_lo[key])
        let [gring1, gring2] = get_arrow_xy(gr1, gr2)
        arrow_list_lo[key].attrs.points = [...gring1.value(), ...gring2.value()]

        if (g_lo.graph_type.is_weighted()) {
            let lab_list_lo = g_lo.get_label_list(data)
            let lab_xy_lo = get_label_xy(gring1, gring2)
            lab_list_lo[key].x(lab_xy_lo.x)
            lab_list_lo[key].y(lab_xy_lo.y)
        }
    }
}

function drag(g_lo) {
    let group_list = g_lo.get_all_group_list()
    group_list.forEach((group_lo) => {
        group_lo.on('dragmove', () => {
            let gr_v_data = group_lo.children[1].attrs.text
            darg_updata(gr_v_data, g_lo)
            let p_to_v_list = g_lo.find_point_v_of_ver(gr_v_data)
            for (const key in p_to_v_list) {
                darg_updata(p_to_v_list[key], g_lo)
            }
            layer.batchDraw();
        })
    })
}



//var group_list = layer.find('Group')


console.log(layer)
console.log(layer_find_group("1"))

function layer_find_group(vdata) {
    var group_list = layer.find('Group')
    var Group_node = nullnode
    console.log(group_list.length)
    for (let key in group_list) {
        if(group_list[key] == group_list.length){
            break
        }
        if(vdata == group_list[key].children[1].attrs.text){
            Group_node = group_list[key]
        }
    }
    return Group_node
}

function add_vertex_visu(v, layer_lo){
    let w = 100, h = 100
    let group = create_group_base(w, h, 25, ...theme, v, true)
    layer.add(group)
}