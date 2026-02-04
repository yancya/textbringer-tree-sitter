# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      # Pascal の tree-sitter ノードタイプは kXxx 形式が多い
      PASCAL_FEATURES = {
        comment: %i[comment],
        string: %i[string],
        keyword: %i[
          kBegin
          kEnd
          kIf
          kThen
          kElse
          kFor
          kTo
          kDownto
          kWhile
          kRepeat
          kUntil
          kDo
          kCase
          kOf
          kWith
          kFunction
          kProcedure
          kProgram
          kUnit
          kInterface
          kImplementation
          kVar
          kConst
          kType
          kArray
          kRecord
          kSet
          kFile
          kClass
          kObject
          kConstructor
          kDestructor
          kProperty
          kInherited
          kPrivate
          kProtected
          kPublic
          kPublished
          kVirtual
          kOverride
          kAbstract
          kStatic
          kForward
          kExternal
          kUses
          kIn
          kNil
          kNot
          kAnd
          kOr
          kXor
          kDiv
          kMod
          kShl
          kShr
          kAs
          kIs
          kTry
          kExcept
          kFinally
          kRaise
          kOn
          kGoto
          kLabel
          kExit
          kBreak
          kContinue
        ],
        number: %i[
          integer
          real
          hex
        ],
        constant: %i[],
        function_name: %i[],
        variable: %i[identifier],
        type: %i[type_identifier],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[
          kTrue
          kFalse
        ],
        property: %i[]
      }.freeze

      PASCAL = PASCAL_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
