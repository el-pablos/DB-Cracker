#!/bin/bash

# Nama root folder proyek
ROOT_DIR="db_cracker"

# Buat fungsi untuk membuat file beserta isi placeholder
create_file() {
  local filepath=$1
  local content=${2:-"// TODO: implement $filepath"}
  mkdir -p "$(dirname "$filepath")"
  echo "$content" > "$filepath"
  echo "Created: $filepath"
}

# Buat root folder
mkdir -p "$ROOT_DIR"

# Pindah ke root folder
cd "$ROOT_DIR" || exit 1

# Buat folder android dan ios
mkdir -p android ios

# Buat struktur lib dan file-file di dalamnya
create_file "lib/main.dart" "void main() {\n  runApp(MyApp());\n}"

create_file "lib/api/pddikti_api.dart"

create_file "lib/models/mahasiswa.dart"
create_file "lib/models/dosen.dart"
create_file "lib/models/prodi.dart"
create_file "lib/models/pt.dart"

create_file "lib/screens/home_screen.dart"
create_file "lib/screens/search_result_screen.dart"
create_file "lib/screens/detail_screen.dart"

create_file "lib/widgets/search_bar.dart"
create_file "lib/widgets/search_result_item.dart"
create_file "lib/widgets/loading_indicator.dart"

create_file "lib/utils/constants.dart"

echo -e "\n✅ Struktur proyek berhasil dibuat di folder: $(pwd)"
