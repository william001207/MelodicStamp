//
//  InspectorView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import Luminare
import SwiftUI

struct InspectorView: View {
    @Bindable var player: PlayerModel
    @Bindable var metadataEditor: MetadataEditorModel

    @State private var isCoverPickerPresented: Bool = false

    var body: some View {
        if metadataEditor.hasEditableMetadata {
            AutoScrollView(.vertical) {
                VStack(spacing: 24) {
                    AdaptableMusicCovers(state: metadataEditor[extracting: \.attachedPictures])
                        .padding(.horizontal, -16)
                        .contentMargins(.horizontal, 16, for: .scrollIndicators)
                        .frame(height: 250)

                    LabeledSection {
                        generalEditor()
                    }

                    LabeledSection {
                        albumEditor()
                    } label: {
                        Text("Album")
                    }

                    LabeledSection {
                        trackAndDiscEditor()
                    } label: {
                        Text("Track and Disc")
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                Spacer()
                    .frame(height: 150)
            }
            .contentMargins(.top, 64)
            .contentMargins(.bottom, 94)
        } else {
            InspectorExcerpt()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder private func generalEditor() -> some View {
        LabeledTextField("Title", text: metadataEditor[extracting: \.title])

        LabeledTextField("Artist", text: metadataEditor[extracting: \.artist])

        LabeledTextField("Composer", text: metadataEditor[extracting: \.composer])
    }

    @ViewBuilder private func albumEditor() -> some View {
        LabeledTextField("Album Title", text: metadataEditor[extracting: \.albumTitle])

        LabeledTextField("Album Artist", text: metadataEditor[extracting: \.albumArtist])
    }

    @ViewBuilder private func trackAndDiscEditor() -> some View {
        LuminarePopover(arrowEdge: .top) {
            switch metadataEditor[extracting: \.bpm] {
            case let .fine(values):
                LuminareStepper(
                    value: .init {
                        CGFloat(values.current ?? .zero)
                    } set: { _ in
                        // do nothing
                    },
                    source: .infinite(),
                    indicatorSpacing: 16,
                    onRoundedValueChange: { _, newValue in
                        values.current = Int(newValue)
                    }
                )
            default:
                EmptyView()
            }
        } badge: {
            LabeledTextField("BPM", state: metadataEditor[extracting: \.bpm], format: .number)
        }
        .luminarePopoverTrigger(.forceTouch)

        HStack {
            LabeledTextField("No.", state: metadataEditor[extracting: \.trackNumber], format: .number, showsLabel: false)
                .frame(maxWidth: 72)

            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)

            LabeledTextField("Tracks", state: metadataEditor[extracting: \.trackTotal], format: .number)
        }

        HStack {
            LabeledTextField("No.", state: metadataEditor[extracting: \.discNumber], format: .number, showsLabel: false)
                .frame(maxWidth: 72)

            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)

            LabeledTextField("Discs", state: metadataEditor[extracting: \.discTotal], format: .number)
        }
    }
}
