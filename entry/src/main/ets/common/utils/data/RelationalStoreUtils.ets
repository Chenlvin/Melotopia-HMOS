import { relationalStore } from '@kit.ArkData'
import { LogUtil } from '@pura/harmony-utils'
import { LocalSong } from '../../entities/Song'

const TAG = '[RelationalStoreUtils] '
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'LocalSongs.db',
  securityLevel: relationalStore.SecurityLevel.S1,
  encrypt: false
}
const TABLE_SONGS = 'songs'

class RelationalStoreUtils {
  private store: relationalStore.RdbStore = {} as relationalStore.RdbStore

  async init() {
    try {
      this.store = await relationalStore.getRdbStore(getContext(), STORE_CONFIG)
    } catch (e) {
      LogUtil.error(TAG, 'Init Store Error: ' + e.message)
    }
    await this.createTables()
  }

  private async createTables() {
    const createTableSql = `
      CREATE TABLE IF NOT EXISTS ${TABLE_SONGS} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        songId INTEGER,
        name TEXT NOT NULL,
        artists TEXT NOT NULL,
        songFile TEXT NOT NULL,
        picFile TEXT,
        lyricFile TEXT
      )`

    try {
      await this.store.executeSql(createTableSql)
    } catch (err) {
      LogUtil.error(TAG, 'Failed to create table: ' + err.message)
    }
  }

  async addSong(item: LocalSong) {
    const valueBucket: relationalStore.ValuesBucket = {
      'songId': item.songId,
      'name': item.name,
      'artists': item.artists,
      'songFile': item.songFile,
      'picFile': item.picFile,
      'lyricFile': item.lyricFile
    }

    try {
      return await this.store.insert(TABLE_SONGS, valueBucket)
    } catch (e) {
      LogUtil.error(TAG, 'Insert song Error: ' + e.message)
      return -1
    }
  }

  /**
   * 获取歌曲
   * @returns LocalSong[]
   */
  async getLocalSongs(limit: number = 0, offset: number = 0): Promise<LocalSong[]> {
    const columns = ['id', 'songId', 'name', 'artists', 'picFile', 'songFile', 'lyricFile']
    const predicates = new relationalStore.RdbPredicates(TABLE_SONGS)
      .orderByDesc('id')
      .limitAs(limit)
      .offsetAs(offset)

    try {
      const resultSet = await this.store.query(predicates, columns)
      return await this.parseResultSet(resultSet)
    } catch (e) {
      LogUtil.error(TAG, 'Failed to get songs: ' + e.message)
      return []
    }
  }

  /**
   * 获取指定数量的歌曲
   * @param limit 需要获取的数量
   * @param offset 偏移量（默认为0）
   * @returns LocalSong[]
   */
  async getSongs(limit: number): Promise<LocalSong[]> {
    const columns = ['id', 'songId', 'name', 'artists', 'picFile', 'songFile', 'lyricFile']
    const predicates = new relationalStore.RdbPredicates(TABLE_SONGS)
      .orderByDesc('id')
      .limitAs(limit)

    try {
      const resultSet = await this.store.query(predicates, columns)
      return await this.parseResultSet(resultSet)
    } catch (e) {
      LogUtil.error(TAG, 'Failed to get songs: ' + e.message)
      return []
    }
  }

  /**
   * 解析查询结果
   * @param resultSet
   * @returns
   */
  private async parseResultSet(resultSet: relationalStore.ResultSet): Promise<LocalSong[]> {
    const list: LocalSong[] = []
    while (resultSet.goToNextRow()) {
      list.push({
        id: resultSet.getDouble(resultSet.getColumnIndex('id')),
        songId: resultSet.getDouble(resultSet.getColumnIndex('songId')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        artists: resultSet.getString(resultSet.getColumnIndex('artists')),
        picFile: resultSet.getString(resultSet.getColumnIndex('picFile')),
        songFile: resultSet.getString(resultSet.getColumnIndex('songFile')),
        lyricFile: resultSet.getString(resultSet.getColumnIndex('lyricFile'))
      })
    }
    return list
  }

  /**
   * 更新歌曲信息
   * @param id 要修改的记录ID
   * @param newData 新歌曲数据
   * @returns 受影响的行数
   */
  async updateSong(id: number, newData: LocalSong): Promise<number> {
    const valueBucket: relationalStore.ValuesBucket = {
      'songId': newData.songId,
      'name': newData.name,
      'artists': newData.artists,
      'songFile': newData.songFile,
      'picFile': newData.picFile,
      'lyricFile': newData.lyricFile
    }
    const predicates = new relationalStore.RdbPredicates(TABLE_SONGS)
      .equalTo('id', id)
    try {
      return await this.store.update(valueBucket, predicates)
    } catch (e) {
      LogUtil.error(TAG, 'Update Error: ' + e.message)
      return 0
    }
  }

  /**
   * 删除
   * @param id
   * @returns
   */
  async deleteSong(id: number): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_SONGS)
      .equalTo('id', id)
    try {
      return await this.store.delete(predicates)
    } catch (e) {
      LogUtil.error(TAG, 'Delete Error: ' + e.message)
      return 0
    }
  }

  /**
   * 清除所有数据
   * @returns
   */
  async clearAllData(): Promise<boolean> {
    try {
      await this.store.executeSql(`DELETE FROM ${TABLE_SONGS}`)
      return true
    } catch (e) {
      LogUtil.error(TAG, 'Clear data failed: ' + e.message)
      return false
    }
  }

  /**
   * 检查歌曲是否存在
   * @param songId
   * @returns 存在返回true 否则false
   */
  async checkSong(songId: number): Promise<boolean> {
    const predicates = new relationalStore.RdbPredicates(TABLE_SONGS)
      .equalTo('songId', songId)
      .limitAs(1)
    try {
      const resultSet = await this.store.query(predicates, ['songId'])
      return resultSet.rowCount > 0
    } catch (e) {
      LogUtil.error(TAG, 'Check song error: ' + e.message)
      return false
    }
  }

}

const relationalStoreUtils = new RelationalStoreUtils()
export default relationalStoreUtils as RelationalStoreUtils