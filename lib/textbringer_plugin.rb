# frozen_string_literal: true

# Textbringer plugin エントリポイント
# Textbringer がプラグインを自動ロードする際に読み込まれる

require "textbringer/tree_sitter/version"
require "textbringer/tree_sitter_config"
require "textbringer/tree_sitter/node_maps"
require "textbringer/tree_sitter_adapter"

# デフォルトの Face を定義
Textbringer::TreeSitterConfig.define_default_faces
