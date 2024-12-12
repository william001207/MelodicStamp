//
//  MetadataView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import Luminare
import SwiftUI

struct MetadataView: View {
    @Bindable var metadataEditor: MetadataEditorModel

    var body: some View {
        if metadataEditor.isVisible {
            AutoScrollView(.vertical) {
                VStack(spacing: 24) {
                    compilationEditor()

                    LabeledSection {
                        sortingEditor()
                    } label: {
                        Text("Sorting")
                    }

                    LabeledSection {
                        albumSortingEditor()
                    } label: {
                        Text("Album Sorting")
                    }
                }
                .padding(.horizontal)
                // don't use `contentMargins()` for content as it breaks progressive blurs
                .safeAreaPadding(.top, 64)
                .safeAreaPadding(.bottom, 94)

                Spacer()
                    .frame(height: 150)
            }
            .contentMargins(.top, 64, for: .scrollIndicators)
            .contentMargins(.bottom, 94, for: .scrollIndicators)
        } else {
            MetadataExcerpt()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder private func compilationEditor() -> some View {
        LabeledOptionalControl(
            state: metadataEditor[extracting: \.isCompilation],
            defaultValue: false
        ) { binding in
            Toggle("", isOn: binding)
                .labelsHidden()
                .toggleStyle(.switch)
        } emptyView: {
            EmptyView()
        } label: {
            Text("Compilation")
        }
    }

    @ViewBuilder private func sortingEditor() -> some View {
        LabeledTextField(
            "Title Sort Order",
            text: metadataEditor[extracting: \.titleSortOrder]
        ) {
            Text("Title")
        }

        LabeledTextField(
            "Artist Sort Order",
            text: metadataEditor[extracting: \.artistSortOrder]
        ) {
            Text("Artist")
        }

        LabeledTextField(
            "Composer Sort Order",
            text: metadataEditor[extracting: \.composerSortOrder]
        ) {
            Text("Composer")
        }

        LabeledTextField(
            "Genre Sort Order",
            text: metadataEditor[extracting: \.genreSortOrder]
        ) {
            Text("Genre")
        }
    }

    @ViewBuilder private func albumSortingEditor() -> some View {
        LabeledTextField(
            "Album Title Sort Order",
            text: metadataEditor[extracting: \.albumTitleSortOrder]
        ) {
            Text("Album Title")
        }

        LabeledTextField(
            "Album Artist Sort Order",
            text: metadataEditor[extracting: \.albumArtistSortOrder]
        ) {
            Text("Album Artist")
        }
    }
}
