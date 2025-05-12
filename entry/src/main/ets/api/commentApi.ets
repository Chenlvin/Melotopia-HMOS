import { CommentResult } from "../common/entities/Comment";
import { COMMENT_SORT_TYPE, COMMENT_TYPE } from "../common/model/Enum";
import commonRequest from "../common/utils/request/RequestUtil";

/**
 * 获取评论信息
 * @param id
 * @param type 0-歌曲, 2-歌单, 3-专辑, 4-电台节目, 7-电台
 * @param pageNo 分页参数 第 N 页
 * @param pageSize 分页参数 每页多少条数据
 * @param sortType 1-按推荐排序, 2-按热度排序, 3-按时间排序
 * @param cursor 当sortType为 3 时且页数不是第一页时需传入 值为上一条数据的 time
 * @returns CommentResult
 */
export const getComment = async (
  id: number,
  type: COMMENT_TYPE,
  pageNo: number = 1,
  pageSize: number = 30,
  sortType: COMMENT_SORT_TYPE,
  cursor?: number
): Promise<CommentResult> => {
  return commonRequest({
    url: '/comment/new',
    params: { id, type, pageNo, pageSize, sortType, cursor }
  })
}
