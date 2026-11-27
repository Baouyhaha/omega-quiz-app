# Bộ icon Rank động vật — Omega Quiz (T12)

Nguồn: **Twemoji** (bộ emoji mã nguồn mở, kho jdecked/twemoji trên GitHub).
Giấy phép: **CC-BY 4.0** — dùng miễn phí cho cả mục đích thương mại, điều kiện duy nhất là ghi công.
Dòng ghi công (đặt ở màn Giới thiệu/Credit của app): "Rank icons by Twemoji, licensed under CC-BY 4.0."

| Rank | Khoảng điểm | File SVG | File PNG 512 |
|---|---|---|---|
| Chuột | 0 – 899 | rank_chuot.svg | rank_chuot.png |
| Mèo | 900 – 999 | rank_meo.svg | rank_meo.png |
| Chó | 1000 – 1099 | rank_cho.svg | rank_cho.png |
| Heo | 1100 – 1199 | rank_heo.svg | rank_heo.png |
| Ngựa | 1200 – 1349 | rank_ngua.svg | rank_ngua.png |
| Gấu | 1350 – 1499 | rank_gau.svg | rank_gau.png |
| Hổ | 1500 – 1649 | rank_ho.svg | rank_ho.png |
| Sư Tử | 1650 – 1799 | rank_sutu.svg | rank_sutu.png |
| Voi | 1800 – 1999 | rank_voi.svg | rank_voi.png |
| Cá Voi Xanh | 2000+ | rank_cavoi.svg | rank_cavoi.png |

Khoảng điểm khớp hàm animalRank trong API (api/src/util.js) và bảng rank đã chốt.
Trong Flutter: khai báo thư mục `assets/icons/rank/` trong pubspec.yaml rồi dùng Image.asset; bản SVG dùng khi cần co giãn sắc nét (qua flutter_svg), bản PNG 512 dùng trực tiếp.
