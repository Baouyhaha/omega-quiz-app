// T13: SoundService — phat am thanh dung/sai/bam/len rank/het gio.
//
// Luat E5: tieng dung/sai CHI phat o man On tap (MH-13). Trong bai thi
// chi phat tieng tap khi chon dap an + tieng timeout khi het gio/bi nop
// cuong buc. Tieng rank_up phat khi len rank (MH-10/MH-14).
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  static const String soundKey = 'sound_enabled';

  /// Am thanh co dang bat khong. Mac dinh bat. Doc lai tu may moi lan
  /// goi nen nut tat trong Cai dat co tac dung ngay.
  Future<bool> get isSoundEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(soundKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(soundKey, value);
  }

  Future<void> _play(String fileName) async {
    if (!await isSoundEnabled) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(0.5);
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
      await player.play(AssetSource('audio/$fileName'));
    } catch (_) {
      // Am thanh loi thi im lang, KHONG lam crash app luc dang thi.
      // Khong nghe tieng = kiem tra lai ten file + khai bao assets.
    }
  }

  /// Tieng dung — CHI goi o che do On tap (MH-13).
  Future<void> playCorrect() => _play('correct.mp3');

  /// Tieng sai — CHI goi o che do On tap (MH-13).
  Future<void> playWrong() => _play('wrong.mp3');

  /// Tieng bam/pop rat nhe — goi khi chon dap an trong bai THI.
  Future<void> playTap() => _play('tap.mp3');

  /// Giai dieu 3 not di len — goi khi len rank (MH-10/MH-14).
  Future<void> playRankUp() => _play('rank_up.mp3');

  /// Chuong mem 1 giay — goi khi het gio tu nop hoac bi nop do
  /// thoat qua 5 lan.
  Future<void> playTimeout() => _play('timeout.mp3');
}
