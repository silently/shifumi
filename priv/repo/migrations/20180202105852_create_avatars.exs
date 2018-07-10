defmodule Shifumi.Repo.Migrations.CreateAvatars do
  use Ecto.Migration

  def change do
    create table(:avatars, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:location, :string)
      add(:mantra, :string)
      add(:nickname, :string)
      add(:picture, :boolean, default: false, null: false)
      add(:roar, :string)
      add(:player_id, references(:players, on_delete: :delete_all, type: :binary_id), null: false)

      timestamps()
    end

    create(unique_index(:avatars, [:player_id]))
    # Nickname unicity
    create(unique_index(:avatars, [:nickname]))
  end
end
