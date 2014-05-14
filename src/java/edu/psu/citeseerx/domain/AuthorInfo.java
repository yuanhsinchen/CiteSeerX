package edu.psu.citeseerx.domain;

public class AuthorInfo {
    private String affiliation;
    private String href;
    private String author;

    public void setAffiliation(String affiliation) {
        this.affiliation = affiliation;
    } //- setAffiliation

    public void setAuthor(String author) {
        this.author = author;
    } //- setAuthor

    public void setHref(String href) {
        this.href = href;
    } //- setHref

    public String getAffiliation() {
        return affiliation;
    } //- getAffiliation

    public String getAuthor() {
        return author;
    } //- getAuthor

    public String getHref() {
        return href;
    } //- getHref
}
